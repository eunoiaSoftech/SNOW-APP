import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snow_app/Grid/grid.dart';
import 'package:snow_app/Grid/profile.dart';

class SnowDashboard extends StatefulWidget {
  const SnowDashboard({super.key});

  @override
  State<SnowDashboard> createState() => _SnowDashboardState();
}

class _SnowDashboardState extends State<SnowDashboard> {
  int _selectedNavIndex = 0;
  String userName = '';

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userFullName') ?? '';
    });
  }

  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Widget _highlightBox(String title, String value, IconData icon) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2), // brighter glass
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3), // strong glass reflection
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.25),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 28, color: Color(0xFF014576)),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF014576),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Color(0xFF014576),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFEAF5FC),
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background image
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
          // Main UI content
          SafeArea(
            child: _selectedNavIndex == 0
                ? _buildDashboardContent()
                : _selectedNavIndex == 1
                ? const GradientGridScreen()
                : ProfileScreen(),
          ),
          // Navigation Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: CurvedNavigationBar(
              index: _selectedNavIndex,
              height: 60.0,
              backgroundColor: Colors.transparent,
              color: const Color.fromARGB(255, 184, 223, 247),
              buttonBackgroundColor: Color(0xFF5E9BC8),
              animationDuration: const Duration(milliseconds: 300),
              animationCurve: Curves.easeInOut,
              items: const <Widget>[
                Icon(Icons.home, size: 30, color: Colors.white),
                Icon(Icons.access_time, size: 30, color: Colors.white),
                Icon(Icons.person_2_rounded, size: 30, color: Colors.white),
              ],
              onTap: (index) {
                setState(() {
                  _selectedNavIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage('assets/woman.png'),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "  Hello, ${capitalize(userName)}",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: const Color(0xFF014576),
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      "  Today ${DateFormat('dd MMM').format(DateTime.now())}",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF014576),
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 2),
              ],
            ),

            const SizedBox(height: 25),

            CarouselSlider(
              options: CarouselOptions(
                height: 160,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.85,
                autoPlayInterval: const Duration(seconds: 3),
              ),
              items:
                  [
                    'assets/growth1.jpg',
                    'assets/growth2.jpg',
                    'assets/growth4.jpg',
                    'assets/growth5.jpg',
                  ].map((imagePath) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    );
                  }).toList(),
            ),

            // // <-- QUICK ACTIONS GRID INSERTED HERE -->
            // _buildQuickActions(),
            const SizedBox(height: 20),

            // ⭐ TODAY'S HIGHLIGHTS STATIC CARDS ⭐
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEAF5FC), Color(0xFFD8E7FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Highlights",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF014576),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ROW 1
                  Row(
                    children: [
                      _highlightBox("SMU Completed", "5", Icons.handshake),
                      const SizedBox(width: 12),
                      _highlightBox(
                        "Opportunities",
                        "3",
                        Icons.lightbulb_outline,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ROW 2
                  Row(
                    children: [
                      _highlightBox("Trainings", "1", Icons.school),
                      const SizedBox(width: 12),
                      _highlightBox("Snow Points", "128", Icons.ac_unit),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // this the api fetch of top givers and top receivers

            // FutureBuilder(
            //   future: Future.wait([
            //     HomeRepository(ApiClient.create()).fetchTopGivers(),
            //     HomeRepository(ApiClient.create()).fetchTopReceivers(),
            //   ]),
            //   builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return const Center(child: CircularProgressIndicator());
            //     } else if (snapshot.hasError) {
            //       return Text("Error: ${snapshot.error}");
            //     } else {
            //       final topGivers = snapshot.data![0] as List<TopGiver>;
            //       final topReceivers = snapshot.data![1] as List<TopReceiver>;

            //       return Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           const SizedBox(height: 10),
            //           Text(
            //             "TOP GIVERS",
            //             style: GoogleFonts.poppins(
            //               fontWeight: FontWeight.bold,
            //               fontSize: 16,
            //               color: const Color(0xFF014576),
            //             ),
            //           ),
            //           const SizedBox(height: 10),
            //           SizedBox(
            //             height: 200,
            //             child: ListView.builder(
            //               scrollDirection: Axis.horizontal,
            //               itemCount: topGivers.length,
            //               itemBuilder: (context, index) {
            //                 final giver = topGivers[index];
            //                 return _buildTopCard(
            //                   giver.displayName,
            //                   giver.business.name ?? 'N/A',
            //                   giver.totalGiven,
            //                   Color(0xFF014576),
            //                   giver.email,
            //                   giver.business.contact ?? "-",
            //                   giver.business.category ?? "-",
            //                   giver.business.website ?? '',
            //                 );
            //               },
            //             ),
            //           ),
            //           const SizedBox(height: 20),
            //           Text(
            //             "TOP RECEIVERS",
            //             style: GoogleFonts.poppins(
            //               fontWeight: FontWeight.bold,
            //               fontSize: 16,
            //               color: const Color(0xFF014576),
            //             ),
            //           ),
            //           const SizedBox(height: 10),
            //           SizedBox(
            //             height: 200,
            //             child: ListView.builder(
            //               scrollDirection: Axis.horizontal,
            //               itemCount: topReceivers.length,
            //               itemBuilder: (context, index) {
            //                 final receiver = topReceivers[index];
            //                 return _buildTopCard(
            //                   receiver.displayName,
            //                   receiver.business.name ?? 'N/A',
            //                   receiver.totalReceived,
            //                   Colors.blue,
            //                   receiver.email,
            //                   receiver.business.contact ?? "-",
            //                   receiver.business.category ?? "-",
            //                   receiver.business.website ?? '',
            //                 );
            //               },
            //             ),
            //           ),
            //         ],
            //       );
            //     }
            //   },
            // ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  const DashboardCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEAF5FC), Color.fromARGB(255, 193, 218, 250)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF014576),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _statusTag("LAST MONTH", Colors.amber),
              const SizedBox(width: 8),
              _statusTag("12 MONTH", Colors.lightGreen),
              const SizedBox(width: 8),
              _statusTag("LIFE TIME", Colors.purple.shade300),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

