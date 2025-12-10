import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class AddSingleFlatScreen extends StatefulWidget {
  const AddSingleFlatScreen({super.key});

  @override
  State<AddSingleFlatScreen> createState() => _AddSingleFlatScreenState();
}

class _AddSingleFlatScreenState extends State<AddSingleFlatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _flatNoController = TextEditingController();
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

  Future<void> _addFlat() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() { _isLoading = true; });

    try {
      await supabase.from('flats').insert({
        'project_id': _selectedProject,
        'flat_no': _flatNoController.text.trim(),
        'status': 'Available',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Flat added successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context,true);
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
    _flatNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Single Flat', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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
              controller: _flatNoController,
              decoration: const InputDecoration(labelText: 'Flat Number (e.g., A-101)', border: OutlineInputBorder()),
              validator: (value) => value!.isEmpty ? 'Please enter a flat number' : null,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _addFlat,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff121212),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Add Flat', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
