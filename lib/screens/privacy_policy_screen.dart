import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const Color primaryColor = Color(0xff121212);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Privacy Policy', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Introduction'),
            _buildParagraph(
                'Welcome to BafnaTrack. We are committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application. Please read this privacy policy carefully.'
            ),
            _buildSectionTitle('Information We Collect'),
            _buildParagraph(
                'We may collect information about you in a variety of ways. The information we may collect via the Application includes:\n\n'
                    'Personal Data: Personally identifiable information, such as your name, shipping address, email address, and telephone number, and demographic information, such as your age, gender, hometown, and interests, that you voluntarily give to us when you register with the Application.'
            ),
            _buildSectionTitle('Use of Your Information'),
            _buildParagraph(
                'Having accurate information about you permits us to provide you with a smooth, efficient, and customized experience. Specifically, we may use information collected about you via the Application to:\n'
                    '- Create and manage your account.\n'
                    '- Email you regarding your account or order.\n'
                    '- Fulfill and manage purchases, orders, payments, and other transactions related to the Application.'
            ),
            _buildSectionTitle('Contact Us'),
            _buildParagraph(
                'If you have questions or comments about this Privacy Policy, please contact us at: [Your Contact Email/Phone]'
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87, height: 1.5),
    );
  }
}
