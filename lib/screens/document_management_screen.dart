import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ProjectDocument {
  final String id;
  final String filePath;
  final String publicUrl;
  ProjectDocument({required this.id, required this.filePath, required this.publicUrl});
}

class DocumentManagementScreen extends StatefulWidget {
  final String projectId;
  final String projectName;
  const DocumentManagementScreen({super.key, required this.projectId, required this.projectName});
  @override
  State<DocumentManagementScreen> createState() => _DocumentManagementScreenState();
}

class _DocumentManagementScreenState extends State<DocumentManagementScreen> {
  late Future<Map<String, List<ProjectDocument>>> _documentsFuture;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _documentsFuture = _fetchDocuments();
  }

  Future<Map<String, List<ProjectDocument>>> _fetchDocuments() async {
    final response = await supabase.from('documents').select().eq('project_id', widget.projectId);
    final List<ProjectDocument> quotations = [];
    final List<ProjectDocument> plans = [];
    for (var doc in response) {
      final filePath = doc['file_path'] as String;
      final publicUrl = supabase.storage.from('projectdocuments').getPublicUrl(filePath);
      final document = ProjectDocument(id: doc['id'].toString(), filePath: filePath, publicUrl: publicUrl);
      if (doc['document_type'] == 'Quotations') {
        quotations.add(document);
      } else if (doc['document_type'] == 'Plans') {
        plans.add(document);
      }
    }
    return {'Quotations': quotations, 'Plans': plans};
  }

  Future<void> _uploadDocument(String docType) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    try {
      final fileName = '${widget.projectName.replaceAll(' ', '_')}_${docType}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${widget.projectId}/$fileName';
      if (kIsWeb) {
        final fileBytes = await image.readAsBytes();
        await supabase.storage.from('projectdocuments').uploadBinary(filePath, fileBytes);
      } else {
        final file = File(image.path);
        await supabase.storage.from('projectdocuments').upload(filePath, file);
      }
      await supabase.from('documents').insert({'project_id': widget.projectId, 'document_type': docType, 'file_path': filePath});
      setState(() { _documentsFuture = _fetchDocuments(); });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$docType uploaded successfully!'), backgroundColor: Colors.green));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${error.toString()}'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _deleteDocument(ProjectDocument doc) async {
    try {
      await supabase.storage.from('projectdocuments').remove([doc.filePath]);
      await supabase.from('documents').delete().eq('id', doc.id);
      setState(() { _documentsFuture = _fetchDocuments(); });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document deleted!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting document: ${e.toString()}'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xff121212),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, List<ProjectDocument>>>(
        future: _documentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No documents found.'));
          }
          final quotations = snapshot.data!['Quotations']!;
          final plans = snapshot.data!['Plans']!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildDocumentSection('Quotations', Icons.request_quote_outlined, quotations),
              const SizedBox(height: 24),
              _buildDocumentSection('Plans', Icons.map_outlined, plans),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDocumentSection(String title, IconData icon, List<ProjectDocument> documents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.black54),
                const SizedBox(width: 8),
                Text(title, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _uploadDocument(title),
              icon: const Icon(Icons.upload_file_outlined, size: 18),
              label: const Text('Upload'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff121212), foregroundColor: Colors.white),
            ),
          ],
        ),
        const Divider(height: 24),
        documents.isEmpty
            ? const Padding(padding: EdgeInsets.symmetric(vertical: 32.0), child: Center(child: Text('No documents uploaded yet.')))
            : GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final doc = documents[index];
            return GridTile(
              footer: GridTileBar(
                backgroundColor: Colors.black45,
                trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.white), onPressed: () => _deleteDocument(doc)),
              ),
              child: Image.network(doc.publicUrl, fit: BoxFit.cover),
            );
          },
        ),
      ],
    );
  }
}