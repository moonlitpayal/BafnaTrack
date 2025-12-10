import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _projectNameController = TextEditingController();
  final _wingsController = TextEditingController();
  final _floorsController = TextEditingController();
  final _flatsPerFloorController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _projectNameController.dispose();
    _wingsController.dispose();
    _floorsController.dispose();
    _flatsPerFloorController.dispose();
    super.dispose();
  }

  Future<void> _generateProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final projectName = _projectNameController.text.trim();
      final wings = _wingsController.text.trim().split(',').map((e) => e.trim().toUpperCase()).toList();
      final floors = int.parse(_floorsController.text.trim());
      final flatsPerFloor = int.parse(_flatsPerFloorController.text.trim());


      await supabase.from('projects').insert({'name': projectName});


      final List<Map<String, dynamic>> flatsToInsert = [];
      for (final wing in wings) {
        for (int floor = 1; floor <= floors; floor++) {
          for (int flatNum = 1; flatNum <= flatsPerFloor; flatNum++) {
            final flatNumber = '$wing${floor * 100 + flatNum}';

            flatsToInsert.add({
              'project_id': projectName,
              'flat_no': flatNumber,
              'status': 'Available',
            });
          }
        }
      }


      if (flatsToInsert.isNotEmpty) {
        await supabase.from('flats').insert(flatsToInsert);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Project "$projectName" and ${flatsToInsert.length} flats created successfully!'),
            backgroundColor: Colors.green.shade700,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Project', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xff121212),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Define Project Structure',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _projectNameController,
                decoration: const InputDecoration(labelText: 'Project Name', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _wingsController,
                decoration: const InputDecoration(labelText: 'Wing Names (e.g., A,B,C)', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter wing names' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _floorsController,
                decoration: const InputDecoration(labelText: 'Number of Floors', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter floor count' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _flatsPerFloorController,
                decoration: const InputDecoration(labelText: 'Flats per Floor', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter flat count per floor' : null,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                onPressed: _generateProject,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generate Project'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff121212),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}