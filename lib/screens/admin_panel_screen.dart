import 'package:bafna_track/screens/add_project_screen.dart';
import 'package:bafna_track/screens/add_single_flat_screen.dart';
import 'package:bafna_track/screens/add_single_gala_screen.dart';
import 'package:bafna_track/screens/document_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;


class ProjectSummary {
  final String id;
  final String name;
  final int totalUnits;
  final int available;
  final int booked;
  final int sold;
  final double totalValue;

  ProjectSummary({
    required this.id,
    required this.name,
    required this.totalUnits,
    required this.available,
    required this.booked,
    required this.sold,
    required this.totalValue,
  });
}

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  late Future<List<ProjectSummary>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    _projectsFuture = _fetchProjectSummaries();
  }

  Future<List<ProjectSummary>> _fetchProjectSummaries() async {
    final results = await Future.wait([
      supabase.from('projects').select('id, name').eq('is_archived', false),
      supabase.from('flats').select('project_id, status, price'),
    ]);

    final projects = results[0] as List;
    final flats = results[1] as List;
    final List<ProjectSummary> summaries = [];

    for (var project in projects) {
      final projectId = project['id'] as String;
      final projectName = project['name'] as String;
      final projectFlats = flats.where((f) => f['project_id'] == projectName).toList();

      double value = 0;
      for (var flat in projectFlats) {
        value += (flat['price'] as num?) ?? 0;
      }

      summaries.add(ProjectSummary(
        id: projectId,
        name: projectName,
        totalUnits: projectFlats.length,
        available: projectFlats.where((f) => f['status'] == 'Available').length,
        booked: projectFlats.where((f) => f['status'] == 'Booked').length,
        sold: projectFlats.where((f) => f['status'] == 'Sold').length,
        totalValue: value,
      ));
    }
    return summaries;
  }

  void _refreshData() {
    setState(() {
      _projectsFuture = _fetchProjectSummaries();
    });
  }

  Future<void> _renameProject(ProjectSummary project) async {
    final nameController = TextEditingController(text: project.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Project'),
        content: TextField(controller: nameController, decoration: const InputDecoration(labelText: 'New Project Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, nameController.text.trim()), child: const Text('Save')),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && mounted) {
      await supabase.from('projects').update({'name': newName}).eq('id', project.id);
      _refreshData();
    }
  }

  Future<void> _archiveProject(ProjectSummary project) async {
    await supabase.from('projects').update({'is_archived': true}).eq('id', project.id);
    _refreshData();
  }

  Future<void> _deleteProject(ProjectSummary project) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project?'),
        content: Text('Are you sure you want to permanently delete "${project.name}" and all its units? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await supabase.from('flats').delete().eq('project_id', project.name);
      await supabase.from('projects').delete().eq('id', project.id);
      _refreshData();
    }
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.add_business_outlined),
            title: const Text('Add New Project'),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProjectScreen()));
              _refreshData();
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_home_outlined),
            title: const Text('Add Single Flat'),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddSingleFlatScreen()));
              _refreshData();
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_shopping_cart_outlined),
            title: const Text('Add Single Gala'),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddSingleGalaScreen()));
              _refreshData();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Admin Panel', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xff121212),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<ProjectSummary>>(
        future: _projectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No projects found. Use the + button to add one.'));
          }
          final projectSummaries = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: projectSummaries.length,
            itemBuilder: (context, index) {
              final project = projectSummaries[index];
              return _buildProjectCard(project);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOptions,
        backgroundColor: const Color(0xff121212),
        foregroundColor: Colors.white,
        tooltip: 'Add...',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProjectCard(ProjectSummary project) {
    final format = NumberFormat.compactCurrency(locale: 'en_IN', symbol: '₹');
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.blueGrey.shade200, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(20, 10, 8, 0),
              leading: const Icon(Icons.business_outlined, color: Color(0xff121212), size: 32),
              title: Text(project.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20)),
              subtitle: Text('${project.totalUnits} Total Units • ${format.format(project.totalValue)}', style: GoogleFonts.poppins()),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'Manage Documents') {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DocumentManagementScreen(projectId: project.id, projectName: project.name)));
                  }
                  if (value == 'Rename') _renameProject(project);
                  if (value == 'Archive') _archiveProject(project);
                  if (value == 'Delete') _deleteProject(project);
                },
                itemBuilder: (BuildContext context) => [
                  _buildPopupMenuItem('Manage Documents', Icons.folder_open_outlined),
                  const PopupMenuDivider(),
                  _buildPopupMenuItem('Rename', Icons.edit_outlined),
                  _buildPopupMenuItem('Archive', Icons.archive_outlined),
                  const PopupMenuDivider(),
                  _buildPopupMenuItem('Delete', Icons.delete_forever_outlined, color: Colors.red),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Available', project.available, Colors.green),
                  _buildStatItem('Booked', project.booked, Colors.orange),
                  _buildStatItem('Sold', project.sold, Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, int count, Color color) {
    return Column(
      children: [
        Text(count.toString(), style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String title, IconData icon, {Color? color}) {
    return PopupMenuItem<String>(
      value: title,
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.black87),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}