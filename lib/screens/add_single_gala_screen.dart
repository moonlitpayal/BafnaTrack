import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class AddSingleGalaScreen extends StatefulWidget {
  const AddSingleGalaScreen({super.key});

  @override
  State<AddSingleGalaScreen> createState() => _AddSingleGalaScreenState();
}

class _AddSingleGalaScreenState extends State<AddSingleGalaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _galaNoController = TextEditingController();
  String? _selectedProject;
  bool _isLoading = false;
  List<String> _projectNames = [];

  @override
  void initState() {
    super.initState();
    _fetchProjectNames();
  }

  Future<void> _fetchProjectNames() async {
    final response = await supabase.from('projects').select('name').eq('is_archived', false);
    if (mounted) {
      setState(() {
        _projectNames = (response as List).map((item) => item['name'] as String).toList();
      });
    }
  }

  Future<void> _addGala() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() { _isLoading = true; });

    try {
      await supabase.from('flats').insert({
        'project_id': _selectedProject,
        'flat_no': _galaNoController.text.trim(),
        'status': 'Available',
        'bhk_type': 'Gala',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gala added successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  void dispose() {
    _galaNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Single Gala', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xff121212),
        foregroundColor: Colors.white,
      ),
      body: _projectNames.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            DropdownButtonFormField<String>(
              value: _selectedProject,
              decoration: const InputDecoration(labelText: 'Select Project', border: OutlineInputBorder()),
              items: _projectNames.map((String name) {
                return DropdownMenuItem<String>(
                  value: name,
                  child: Text(name),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedProject = newValue;
                });
              },
              validator: (value) => value == null ? 'Please select a project' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _galaNoController,
              decoration: const InputDecoration(labelText: 'Gala / Shop Number', border: OutlineInputBorder()),
              validator: (value) => value!.isEmpty ? 'Please enter a number' : null,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _addGala,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff121212),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Add Gala', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}