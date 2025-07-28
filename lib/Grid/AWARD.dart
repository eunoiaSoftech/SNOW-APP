import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AwardsScreen extends StatelessWidget {
  final List<Map<String, String>> awards = [
    {'title': 'Team Spirit', 'by': 'Management', 'image': 'assets/pic3.jpg'},
    {
      'title': 'Creative Excellence',
      'by': 'SnowTech',
      'image': 'assets/pic4.jpg',
    },
    {
      'title': 'Leadership Star',
      'by': 'Management',
      'image': 'assets/pic5.jpg',
    },
    {'title': 'Best Performer', 'by': 'Gorukul', 'image': 'assets/pic1.jpg'},
    {'title': 'Innovation Award', 'by': 'SnowTech', 'image': 'assets/pic2.jpg'},
  ];

  final List<Color> gradientColors = [Color(0xFFEAF5FC), Color(0xFFD8E7FA)];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Awards',
          style: GoogleFonts.poppins(
            color: const Color(0xFF014576),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        excludeHeaderSemantics: true,
        // centerTitle: true,
      ),
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
                        Color(0xAA70A9EE),
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
          ListView.builder(
            itemCount: awards.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final award = awards[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: award['image'] != null
                            ? Image.asset(
                                award['image']!,
                                width: double.infinity,
                                fit: BoxFit.fitWidth,
                              )
                            : Container(
                                height: 180,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.image,
                                  size: 60,
                                  color: Colors.grey[500],
                                ),
                              ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.emoji_events_rounded,
                                  color: Color(0xFF014576),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    award['title']!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF014576),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.person_pin_circle,
                                  color: Colors.black45,
                                  size: 18,
                                ),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Awarded by ${award['by']}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
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
        ],
      ),
    );
  }
}
