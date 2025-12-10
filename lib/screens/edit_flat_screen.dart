import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/flat_model.dart';

final supabase = Supabase.instance.client;

class EditFlatScreen extends StatefulWidget {
  final Flat flat;
  const EditFlatScreen({super.key, required this.flat});
  @override
  State<EditFlatScreen> createState() => _EditFlatScreenState();
}

class _EditFlatScreenState extends State<EditFlatScreen> {
  final _formKey = GlobalKey<FormState>();


  late TextEditingController _priceController;
  late TextEditingController _areaController;
  late TextEditingController _ownerNameController;
  late TextEditingController _bhkTypeController;
  late TextEditingController _floorController;
  late TextEditingController _facingController;
  late TextEditingController _notesController;
  late TextEditingController _customerPhoneController;
  late TextEditingController _agreementValueController;
  late TextEditingController _extraWorkAmountController;
  late TextEditingController _amountPaidController;
  late TextEditingController _loanAmountController;
  late TextEditingController _completionPercentageController;

  String? _parkingSelection;
  String? _quotationImagePath;
  bool _hasLoan = false;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();


  double _totalCost = 0;
  double _remainingBalance = 0;
  double _amountDueFromBank = 0;

  @override
  void initState() {
    super.initState();

    _priceController = TextEditingController(text: widget.flat.price?.toStringAsFixed(0) ?? '');
    _areaController = TextEditingController(text: widget.flat.area?.toStringAsFixed(0) ?? '');
    _ownerNameController = TextEditingController(text: widget.flat.ownerName ?? '');
    _bhkTypeController = TextEditingController(text: widget.flat.bhkType ?? '');
    _floorController = TextEditingController(text: widget.flat.floor ?? '');
    _facingController = TextEditingController(text: widget.flat.facing ?? '');
    _notesController = TextEditingController(text: widget.flat.notes ?? '');
    _customerPhoneController = TextEditingController(text: widget.flat.customerPhone ?? '');
    _agreementValueController = TextEditingController(text: widget.flat.agreementValue?.toStringAsFixed(0) ?? '');
    _extraWorkAmountController = TextEditingController(text: widget.flat.extraWorkAmount?.toStringAsFixed(0) ?? '');
    _amountPaidController = TextEditingController(text: widget.flat.amountPaidTillDate?.toStringAsFixed(0) ?? '');
    _loanAmountController = TextEditingController(text: widget.flat.loanAmount?.toStringAsFixed(0) ?? '');
    _completionPercentageController = TextEditingController(text: widget.flat.projectCompletionPercentage?.toStringAsFixed(0) ?? '');
    _parkingSelection = widget.flat.parking;
    _quotationImagePath = widget.flat.quotationImagePath;
    _hasLoan = widget.flat.hasLoan ?? false;


    _agreementValueController.addListener(_calculateFinancials);
    _extraWorkAmountController.addListener(_calculateFinancials);
    _amountPaidController.addListener(_calculateFinancials);
    _loanAmountController.addListener(_calculateFinancials);
    _completionPercentageController.addListener(_calculateFinancials);

    _calculateFinancials();
  }

  void _calculateFinancials() {
    final agreementValue = double.tryParse(_agreementValueController.text) ?? 0;
    final extraWork = double.tryParse(_extraWorkAmountController.text) ?? 0;
    final amountPaid = double.tryParse(_amountPaidController.text) ?? 0;

    setState(() {
      _totalCost = agreementValue + extraWork;

      if (_hasLoan) {
        final loanAmount = double.tryParse(_loanAmountController.text) ?? 0;
        final completion = double.tryParse(_completionPercentageController.text) ?? 0;
        _amountDueFromBank = loanAmount * (completion / 100);
      } else {
        _amountDueFromBank = 0;
      }

      _remainingBalance = _totalCost - amountPaid - _amountDueFromBank;
    });
  }


  @override
  void dispose() {

    _priceController.dispose();
    _areaController.dispose();
    _ownerNameController.dispose();
    _bhkTypeController.dispose();
    _floorController.dispose();
    _facingController.dispose();
    _notesController.dispose();
    _customerPhoneController.dispose();
    _agreementValueController.dispose();
    _extraWorkAmountController.dispose();
    _amountPaidController.dispose();
    _loanAmountController.dispose();
    _completionPercentageController.dispose();
    super.dispose();
  }

  Future<void> _uploadQuotation() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() { _isLoading = true; });
    try {
      final fileName = 'quotation_${widget.flat.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${widget.flat.projectId}/${widget.flat.id}/$fileName';
      if (kIsWeb) {
        final fileBytes = await image.readAsBytes();
        await supabase.storage.from('projectdocuments').uploadBinary(filePath, fileBytes);
      } else {
        final file = File(image.path);
        await supabase.storage.from('projectdocuments').upload(filePath, file);
      }
      setState(() { _quotationImagePath = filePath; });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: ${error.toString()}'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) { setState(() { _isLoading = false; }); }
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; });
    try {
      final updates = {
        'price': double.tryParse(_priceController.text),
        'area': double.tryParse(_areaController.text),
        'owner_name': _ownerNameController.text.trim(),
        'bhk_type': _bhkTypeController.text.trim(),
        'floor': _floorController.text.trim(),
        'facing': _facingController.text.trim(),
        'parking': _parkingSelection,
        'notes': _notesController.text.trim(),
        'customer_phone': _customerPhoneController.text.trim(),
        'quotation_image_path': _quotationImagePath,
        'agreement_value': double.tryParse(_agreementValueController.text),
        'extra_work_amount': double.tryParse(_extraWorkAmountController.text),
        'amount_paid_till_date': double.tryParse(_amountPaidController.text),
        'has_loan': _hasLoan,
        'loan_amount': _hasLoan ? double.tryParse(_loanAmountController.text) : null,
        'project_completion_percentage': _hasLoan ? double.tryParse(_completionPercentageController.text) : null,
      };
      await supabase.from('flats').update(updates).eq('id', widget.flat.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Details successfully saved!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving details: ${error.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) { setState(() { _isLoading = false; }); }
    }
  }

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Edit Flat ${widget.flat.flatNo}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xff121212),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt_outlined),
            onPressed: _isLoading ? null : _saveChanges,
            tooltip: 'Save Changes',
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildLiveSummaryCard(format),
            const SizedBox(height: 16),
            _buildCard(
                title: 'Property Details',
                icon: Icons.home_work_outlined,
                children: [
                  _buildTextField(_priceController, 'Price', icon: Icons.currency_rupee, keyboardType: TextInputType.number),
                  _buildTextField(_areaController, 'Area (sq.ft)', icon: Icons.area_chart_outlined, keyboardType: TextInputType.number),
                  _buildTextField(_bhkTypeController, 'BHK Type (e.g., 2BHK)', icon: Icons.bed_outlined),
                  _buildTextField(_floorController, 'Floor (e.g., 1st Floor)', icon: Icons.arrow_upward_outlined),
                  _buildTextField(_facingController, 'Facing (e.g., East)', icon: Icons.explore_outlined),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Parking Slot', style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54)),
                        const SizedBox(height: 8),
                        Center(
                          child: ToggleButtons(
                            isSelected: [_parkingSelection == 'None', _parkingSelection == 'A', _parkingSelection == 'B'],
                            onPressed: (index) {
                              setState(() {
                                if (index == 0) _parkingSelection = 'None';
                                if (index == 1) _parkingSelection = 'A';
                                if (index == 2) _parkingSelection = 'B';
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            selectedColor: Colors.white,
                            fillColor: const Color(0xff121212),
                            children: const [
                              Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('None')),
                              Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('A')),
                              Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('B')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ]
            ),
            const SizedBox(height: 16),
            _buildCard(
                title: 'Customer & Financials',
                icon: Icons.person_outline,
                children: [
                  _buildTextField(_ownerNameController, 'Owner Name'),
                  _buildTextField(_customerPhoneController, 'Customer Phone', keyboardType: TextInputType.phone),
                  const Divider(height: 20),
                  _buildTextField(_agreementValueController, 'Agreement Value', keyboardType: TextInputType.number),
                  _buildTextField(_extraWorkAmountController, 'Extra Work (EW) Amount', keyboardType: TextInputType.number),
                  _buildTextField(_amountPaidController, 'Amount Paid Till Date', keyboardType: TextInputType.number),
                  SwitchListTile(
                    title: Text('Has Loan?', style: GoogleFonts.poppins(fontSize: 16)),
                    value: _hasLoan,
                    onChanged: (value) {
                      setState(() { _hasLoan = value; });
                      _calculateFinancials();
                    },
                    secondary: const Icon(Icons.credit_card, color: Colors.black54),
                    activeColor: const Color(0xff121212),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: _hasLoan
                        ? Column(
                      children: [
                        const Divider(),
                        _buildTextField(_loanAmountController, 'Total Loan Amount', keyboardType: TextInputType.number),
                        _buildTextField(_completionPercentageController, 'Project Completion %', keyboardType: TextInputType.number),
                      ],
                    )
                        : const SizedBox.shrink(),
                  ),
                ]
            ),
            const SizedBox(height: 16),
            _buildCard(
                title: 'Documents & Notes',
                icon: Icons.folder_copy_outlined,
                children: [
                  _buildTextField(_notesController, 'Notes', maxLines: 4),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.request_quote_outlined, color: Colors.black54),
                    title: Text('Quotation', style: GoogleFonts.poppins(fontSize: 16)),
                    subtitle: Text(_quotationImagePath == null ? 'No image uploaded' : 'Image is attached'),
                    trailing: ElevatedButton(
                      onPressed: _uploadQuotation,
                      child: const Text('Upload'),
                    ),
                  )
                ]
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _saveChanges,
              icon: const Icon(Icons.save),
              label: Text('Save Changes', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff121212),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveSummaryCard(NumberFormat format) {
    return Card(
      elevation: 4,
      color: Colors.blueGrey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildFinancialRow('Total Cost', format.format(_totalCost), isBold: true),
            _buildFinancialRow('Amount Paid', format.format(double.tryParse(_amountPaidController.text) ?? 0), color: Colors.green.shade800),
            if (_hasLoan)
              _buildFinancialRow('Due from Bank', format.format(_amountDueFromBank), color: Colors.blue.shade800),
            const Divider(thickness: 1, height: 20),
            _buildFinancialRow('Remaining Balance', format.format(_remainingBalance), isBold: true, color: Colors.red.shade800),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54)),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.black54),
                const SizedBox(width: 8),
                Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 24),
            ...children
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {IconData? icon, TextInputType? keyboardType, int? maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: Colors.black54) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          floatingLabelStyle: const TextStyle(color: Color(0xff121212)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xff121212), width: 2),
          ),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: GoogleFonts.poppins(),
      ),
    );
  }
}