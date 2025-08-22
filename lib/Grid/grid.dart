import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/Grid/AWARD.dart';
import 'package:snow_app/Grid/RecordSFGScreen.dart';
import 'package:snow_app/Grid/SnowMeetupForm.dart';
import 'package:snow_app/Grid/UpcomingTrainingsScreen.dart';
import 'package:snow_app/Grid/myreferral.dart';
import 'package:snow_app/Grid/recived_referrals.dart';
import 'package:snow_app/Grid/sbog.dart';

class GradientGridScreen extends StatelessWidget {
  const GradientGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> boxTitles = [
      // 'TRAININGS',
      'RECORD SBOG',
      'RECORD SFG',
      "SNOW MEETUP'S",
      'AWARDS',
    ];

    final List<Widget> screens = [
      // UpcomingTrainingsScreen(),
      MyReferralsScreen(),
      ReceivedReferralsScreen(),
      SnowMeetupScreen(),
      AwardsScreen(),
    ];

    final List<IconData> icons = [
      Icons.school_rounded, // TRAININGS
      Icons.receipt_long_rounded, // RECORD SBOG
      Icons.assignment_turned_in, // RECORD SFG
      Icons.ac_unit_rounded, // SNOW MEETUP'S
      Icons.emoji_events_rounded, // AWARDS
    ];
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Image & Overlay Gradient
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

          // Custom Header + Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Header Title
                Center(
                  child: Text(
                    'Grid Menu',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF014576),
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Color.fromARGB(150, 200, 240, 255),
                          offset: Offset(1, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // Grid View Expanded
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: List.generate(boxTitles.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => screens[index],
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFEAF5FC),
                                Color.fromARGB(255, 193, 218, 250),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                icons[index],
                                size: 40,
                                color: Color(0xAA5E9BC8),
                              ),
                              SizedBox(height: 10),
                              Text(
                                boxTitles[index],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: Color(0xFF014576),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 4,
                                      color: Color.fromARGB(255, 191, 221, 243),
                                      offset: Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
