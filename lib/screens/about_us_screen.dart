import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  static const Color primaryColor = Color(0xff121212);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('About Us', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.business_outlined,
                size: 50,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Dbafna Group',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'A Legacy of Excellence and Trust',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            Text(
              'For decades, the Dbafna Group has been a cornerstone of development and a symbol of unwavering trust in the Raigad region. Our legacy is built not just on structures, but on a steadfast commitment to quality, innovation, and progress.\n\nWe are dedicated to shaping a better future through our diverse portfolio, which includes the construction of premium residential and commercial properties, the development of critical road infrastructure that connects communities, and the operation of high-grade Ready Mix Concrete (RMC) plants that form the foundation of robust construction.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.black87,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),
            Text(
              'The BafnaTrack application is a digital extension of our commitment to excellence. It is designed to bring greater transparency, efficiency, and streamlined management to our projects, reflecting our forward-thinking approach.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.black87,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'This application was made possible by the vision and guidance of Mr. Darshan Bafna. I extend my deepest gratitude for his invaluable support and for providing me with this opportunity. This app is a tribute to his leadership.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.black87,
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Developed with profound respect and dedication.',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}