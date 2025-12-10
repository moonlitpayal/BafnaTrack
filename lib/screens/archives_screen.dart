import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ArchivedProject {
  final String id;
  final String name;
  ArchivedProject({required this.id, required this.name});
}

class ArchivesScreen extends StatefulWidget {
  const ArchivesScreen({super.key});

  @override
  State<ArchivesScreen> createState() => _ArchivesScreenState();
}

class _ArchivesScreenState extends State<ArchivesScreen> {
  late Future<List<ArchivedProject>> _archivedProjectsFuture;

  static const Color primaryColor = Color(0xff121212);

  @override
  void initState() {
    super.initState();
    _archivedProjectsFuture = _fetchArchivedProjects();
  }

  Future<List<ArchivedProject>> _fetchArchivedProjects() async {

    final response = await supabase
        .from('projects')
        .select('id, name')
        .eq('is_archived', true);

    return (response as List)
        .map((p) => ArchivedProject(id: p['id'], name: p['name']))
        .toList();
  }

  void _refreshData() {
    setState(() {
      _archivedProjectsFuture = _fetchArchivedProjects();
    });
  }

  Future<void> _unarchiveProject(ArchivedProject project) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Restore Project', style: GoogleFonts.poppins()),
        content: Text('Are you sure you want to restore the project "${project.name}"?'),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(ctx).pop(false)),
          ElevatedButton(child: const Text('Confirm'), onPressed: () => Navigator.of(ctx).pop(true)),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await supabase.from('projects').update({'is_archived': false}).eq('id', project.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${project.name}" has been restored.'), backgroundColor: Colors.green.shade700),
      );
      _refreshData();
    }
  }

  Future<void> _deleteProject(ArchivedProject project) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Permanently?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('This action is irreversible. All data for "${project.name}" will be lost forever. Are you absolutely sure?'),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(ctx).pop(false)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
            child: const Text('Yes, Delete'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await supabase.from('flats').delete().eq('project_id', project.name);
      await supabase.from('projects').delete().eq('id', project.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${project.name}" has been permanently deleted.'), backgroundColor: Colors.red.shade700),
      );
      _refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Archived Projects', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<ArchivedProject>>(
        future: _archivedProjectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final archivedProjects = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: archivedProjects.length,
            itemBuilder: (context, index) {
              final project = archivedProjects[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.only(left: 20, right: 10),
                  leading: const Icon(Icons.archive_outlined, color: Colors.grey, size: 30),
                  title: Text(
                    project.name,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black54),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.unarchive_outlined),
                        color: Colors.green.shade700,
                        tooltip: 'Restore',
                        onPressed: () => _unarchiveProject(project),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever_outlined),
                        color: Colors.red.shade700,
                        tooltip: 'Delete Permanently',
                        onPressed: () => _deleteProject(project),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Archived Projects',
            style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Archived projects will appear here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}