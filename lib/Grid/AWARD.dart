import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AwardsScreen extends StatefulWidget {
  @override
  State<AwardsScreen> createState() => _AwardsScreenState();
}

class _AwardsScreenState extends State<AwardsScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, String>> awards = [
    {'title': 'Team Spirit', 'by': 'Management', 'image': 'assets/pic3.jpg'},
    {'title': 'Creative Excellence', 'by': 'SnowTech', 'image': 'assets/pic4.webp'},
    {'title': 'Leadership Star', 'by': 'Management', 'image': 'assets/pic5.jpg'},
    {'title': 'Best Performer', 'by': 'Gorukul', 'image': 'assets/pic1.webp'},
    {'title': 'Innovation Award', 'by': 'SnowTech', 'image': 'assets/pic2.webp'},
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background with gradient
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
                      Color(0xAA70A9EE),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ],
          ),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'AWARDS',
              style: GoogleFonts.poppins(
                color: Color(0xFF014576),
                fontWeight: FontWeight.w700,
                fontSize: 22,
                shadows: [
                  Shadow(
                    blurRadius: 4,
                    color: Color.fromARGB(150, 200, 240, 255),
                    offset: Offset(1, 2),
                  ),
                ],
              ),
            ),
            iconTheme: IconThemeData(color: Color(0xFF014576)),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: awards.length,
            itemBuilder: (context, index) {
              final award = awards[index];
              return AnimatedContainer(
                duration: Duration(milliseconds: 400 + (index * 100)),
                curve: Curves.easeOut,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    children: [
                      // No blur on image
                      Image.asset(
                        award['image']!,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                      ),

                      // Info section with light background and elevation
                      Container(
                        width: double.infinity,
                        color: Colors.white.withOpacity(0.85),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.emoji_events_rounded,
                                  color: Color(0xFF014576),
                                  size: 22,
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    award['title']!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF014576),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Awarded by ${award['by']}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
