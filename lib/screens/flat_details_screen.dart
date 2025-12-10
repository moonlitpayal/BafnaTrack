import 'package:bafna_track/screens/full_screen_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/flat_model.dart';
import 'edit_flat_screen.dart';

final supabase = Supabase.instance.client;

class FlatDetailsScreen extends StatefulWidget {
  final Flat initialFlat;
  const FlatDetailsScreen({super.key, required this.initialFlat});
  @override
  State<FlatDetailsScreen> createState() => _FlatDetailsScreenState();
}

class _FlatDetailsScreenState extends State<FlatDetailsScreen> {
  late Flat flat;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    flat = widget.initialFlat;
  }

  Future<void> _updateFlatStatus(String newStatus) async {
    setState(() { _isLoading = true; });
    try {
      await supabase.from('flats').update({'status': newStatus}).eq('id', flat.id);
      setState(() {
        flat = flat.copyWith(status: newStatus);
        _hasChanges = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Flat ${flat.flatNo} was marked as "$newStatus".'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Could not update status.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) { setState(() { _isLoading = false; }); }
    }
  }

  @override
  Widget build(BuildContext context) {

    final agreementValue = flat.agreementValue ?? 0;
    final extraWork = flat.extraWorkAmount ?? 0;
    final totalCost = agreementValue + extraWork;
    final amountPaid = flat.amountPaidTillDate ?? 0;

    double amountDueFromBank = 0;
    if (flat.hasLoan == true) {
      final loanAmount = flat.loanAmount ?? 0;
      final completion = flat.projectCompletionPercentage ?? 0;
      amountDueFromBank = loanAmount * (completion / 100);
    }


    final balanceAmount = totalCost - amountPaid - amountDueFromBank;

    final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _hasChanges);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: Text('Flat ${flat.flatNo}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xff121212),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _hasChanges),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_note_outlined),
              tooltip: 'Edit Details',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditFlatScreen(flat: flat),
                  ),
                );
                if (result == true && mounted) {
                  _hasChanges = true;
                  final freshData = await supabase.from('flats').select().eq('id', flat.id).single();
                  setState(() {
                    flat = Flat.fromJson(freshData);
                  });
                }
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),

            _buildFinancialDashboard(totalCost, amountPaid, balanceAmount, amountDueFromBank, format),

            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Property Details',
              icon: Icons.home_work_outlined,
              details: {
                'Project': flat.projectId,
                'Area': '${flat.area?.toInt() ?? 'N/A'} sq.ft.',
                'BHK Type': flat.bhkType ?? 'N/A',
                'Floor': flat.floor ?? 'N/A',
                'Facing': flat.facing ?? 'N/A',
                'Parking': flat.parking ?? 'N/A',
              },
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Customer Details',
              icon: Icons.person_pin_circle_outlined,
              details: {
                'Owner Name': flat.ownerName ?? 'N/A',
                'Customer Phone': flat.customerPhone ?? 'N/A',
              },
              extraWidget: _buildQuotationViewer(),
            ),
            const SizedBox(height: 16),
            if (flat.notes != null && flat.notes!.isNotEmpty)
              _buildInfoCard(
                title: 'Notes',
                icon: Icons.note_alt_outlined,
                details: {'': flat.notes!},
              ),
            const SizedBox(height: 24),
            _isLoading ? const Center(child: CircularProgressIndicator()) : _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialDashboard(double totalCost, double amountPaid, double balanceAmount, double amountDueFromBank, NumberFormat format) {
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
                const Icon(Icons.account_balance_wallet_outlined, color: Colors.black54),
                const SizedBox(width: 8),
                Text('Financial Summary', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 24),
            _buildFinancialRow('Agreement Value', format.format(flat.agreementValue ?? 0)),
            _buildFinancialRow('Extra Work Amount', format.format(flat.extraWorkAmount ?? 0)),
            const Divider(thickness: 1, height: 20),
            _buildFinancialRow('Total Cost', format.format(totalCost), isBold: true),
            _buildFinancialRow('Amount Paid Till Date', format.format(amountPaid), color: Colors.green.shade800),
            const Divider(thickness: 1, height: 20),
            _buildFinancialRow('Remaining Balance', format.format(balanceAmount), isBold: true, color: Colors.red.shade800),
            if (flat.hasLoan == true) ...[
              const Divider(height: 20, indent: 20, endIndent: 20),
              _buildFinancialRow('Total Loan Amount', format.format(flat.loanAmount ?? 0)),
              _buildFinancialRow('Amount Due from Bank (${flat.projectCompletionPercentage ?? 0}%)', format.format(amountDueFromBank), color: Colors.blue.shade800),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54)),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: color ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildQuotationViewer() {
    if (flat.quotationImagePath == null || flat.quotationImagePath!.isEmpty) {
      return const SizedBox.shrink();
    }
    final imageUrl = supabase.storage.from('projectdocuments').getPublicUrl(flat.quotationImagePath!);
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quotation:', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black54)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FullScreenImageViewer(imageUrl: imageUrl)));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => const Center(child: Text('Could not load image')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      color: _getStatusColor(flat.status).withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: _getStatusColor(flat.status), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Status: ', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
            Text(flat.status ?? 'N/A', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: _getStatusColor(flat.status))),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required IconData icon, required Map<String, String> details, Widget? extraWidget}) {
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
            ...details.entries.map((entry) => _buildDetailRow(entry.key, entry.value)),
            if (extraWidget != null) extraWidget,
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (flat.status == 'Available')
          _buildActionButton(text: 'Mark as Booked', icon: Icons.bookmark_add_outlined, color: Colors.orange.shade700, onPressed: () => _updateFlatStatus('Booked')),
        if (flat.status == 'Booked' || flat.status == 'Available')
          _buildActionButton(text: 'Mark as Sold', icon: Icons.sell_outlined, color: Colors.red.shade700, onPressed: () => _updateFlatStatus('Sold')),
        if (flat.status == 'Booked' || flat.status == 'Sold')
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: _buildActionButton(text: 'Mark as Available', icon: Icons.check_circle_outline, color: Colors.green.shade700, onPressed: () => _updateFlatStatus('Available')),
          ),
      ],
    );
  }

  Widget _buildActionButton({required String text, required IconData icon, required Color color, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Text('$label:', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black54)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: label.isEmpty ? TextAlign.start : TextAlign.end,
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Available': return Colors.green.shade800;
      case 'Booked': return Colors.orange.shade800;
      case 'Sold': return Colors.red.shade800;
      default: return Colors.grey.shade800;
    }
  }
}