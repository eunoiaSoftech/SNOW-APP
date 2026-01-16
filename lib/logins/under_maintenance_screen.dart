import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UnderMaintenanceScreen extends StatelessWidget {
  final String message;

  const UnderMaintenanceScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF5E9BC8);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/bghome.jpg', fit: BoxFit.cover),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xAA97DCEB),
                        Color(0xAA5E9BC8),
                        Color(0xAA97DCEB),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: primaryBlue.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.2),
                          blurRadius: 18,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.build_circle_outlined,
                          size: 64,
                          color: primaryBlue,
                        ),
                        const SizedBox(height: 18),

                        Text(
                          'Under Maintenance',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF014576),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14.5,
                            color: Colors.grey[700],
                          ),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          'Thank you for your patience ❄️',
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
