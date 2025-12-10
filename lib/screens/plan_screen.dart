import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'full_screen_image_viewer.dart';

final supabase = Supabase.instance.client;

class ProjectInfo {
  final String id;
  final String name;
  ProjectInfo(this.id, this.name);
}

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});
  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  late Future<List<ProjectInfo>> _projectsFuture;
  ProjectInfo? _selectedProject;
  List<String> _imageUrls = [];
  bool _isLoadingImages = false;

  @override
  void initState() {
    super.initState();
    _projectsFuture = _fetchProjects();
  }

  Future<List<ProjectInfo>> _fetchProjects() async {
    final response = await supabase.from('projects').select('id, name').eq('is_archived', false);
    return (response as List).map((p) => ProjectInfo(p['id'], p['name'])).toList();
  }

  Future<void> _fetchProjectImages(String projectId) async {
    setState(() { _isLoadingImages = true; _imageUrls = []; });
    final response = await supabase.from('documents').select('file_path').eq('project_id', projectId).eq('document_type', 'Plans');
    final urls = <String>[];
    for (var doc in response) {
      final publicUrl = supabase.storage.from('projectdocuments').getPublicUrl(doc['file_path']);
      urls.add(publicUrl);
    }
    setState(() { _imageUrls = urls; _isLoadingImages = false; });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xff121212);
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('View Plans', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<List<ProjectInfo>>(
              future: _projectsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final projects = snapshot.data!;
                return DropdownButtonFormField<ProjectInfo>(
                  value: _selectedProject,
                  decoration: const InputDecoration(labelText: 'Select a Project to View Plans', border: OutlineInputBorder()),
                  items: projects.map((ProjectInfo project) {
                    return DropdownMenuItem<ProjectInfo>(value: project, child: Text(project.name));
                  }).toList(),
                  onChanged: (ProjectInfo? newValue) {
                    setState(() { _selectedProject = newValue; });
                    if (newValue != null) {
                      _fetchProjectImages(newValue.id);
                    }
                  },
                );
              },
            ),
          ),
          Expanded(
            child: _isLoadingImages
                ? const Center(child: CircularProgressIndicator())
                : _imageUrls.isEmpty
                ? Center(child: Text(_selectedProject == null ? 'Please select a project.' : 'No plans found for this project.', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600])))
                : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16),
              itemCount: _imageUrls.length,
              itemBuilder: (context, index) {
                final imageUrl = _imageUrls[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImageViewer(imageUrl: imageUrl),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator()),
                      errorBuilder: (context, error, stack) => const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}