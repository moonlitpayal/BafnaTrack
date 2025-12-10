import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  static const Color primaryColor = Color(0xff121212);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Terms of Service', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Agreement to Terms'),
            _buildParagraph(
                'By using our mobile application, BafnaTrack, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the Application.'
            ),
            _buildSectionTitle('User Accounts'),
            _buildParagraph(
                'When you create an account with us, you must provide us information that is accurate, complete, and current at all times. Failure to do so constitutes a breach of the Terms, which may result in immediate termination of your account on our Service.'
            ),
            _buildSectionTitle('Intellectual Property'),
            _buildParagraph(
                'The Application and its original content, features, and functionality are and will remain the exclusive property of Dbafna Group and its licensors. The Service is protected by copyright, trademark, and other laws of both India and foreign countries.'
            ),
            _buildSectionTitle('Governing Law'),
            _buildParagraph(
                'These Terms shall be governed and construed in accordance with the laws of India, without regard to its conflict of law provisions. Thats it it was for the terams and condition there is not any kind of the information that is not available in the terms and condition and it is teh termas and condition that is availabe in the terms and condition so read wise and no we ande not taking any kind of permissions so dont worry your data and all is safe, we dont theif and if we want anything then i will ask for that okay'
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
