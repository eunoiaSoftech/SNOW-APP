import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snow_app/Grid/AWARD.dart';
import 'package:snow_app/Grid/grid.dart';
import 'package:snow_app/Grid/profile.dart';
import 'package:snow_app/home/admin.dart';

class SnowDashboard extends StatefulWidget {
  const SnowDashboard({super.key});

  @override
  State<SnowDashboard> createState() => _SnowDashboardState();
}

class _SnowDashboardState extends State<SnowDashboard> {
  int _selectedDateIndex = 0;
  int _selectedNavIndex = 0;
  String userName = '';

  List<DateTime> get _next7Days {
    final today = DateTime.now();
    return List.generate(7, (index) => today.add(Duration(days: index)));
  }

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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFEAF5FC),
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return SafeArea(
      child: Scaffold(
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
            Padding(
              padding: const EdgeInsets.only(bottom: 60.0),
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
      ),
    );
  }

  // logout
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  // await prefs.setBool('isLoggedIn', false);
  // Navigator.pushAndRemoveUntil(
  //   context,
  //   MaterialPageRoute(builder: (context) => const LoginPage()),
  //   (Route<dynamic> route) => false,
  // );

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
                      "  Hello, ${capitalize(userName)}!",
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
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminApprovalScreen(),
                      ),
                    );
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications,
                        size: 28,
                        color: Colors.white,
                      ),

                      // Badge
                      Positioned(
                        right: -1,
                        top: -5,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.red.shade300,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 15,
                            minHeight: 15,
                          ),
                          child: const Center(
                            child: Text(
                              '2',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Daily Challenge Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFEAF5FC),
                    Color.fromARGB(255, 193, 218, 250),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Daily challenge",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: const Color(0xFF014576),

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Do your plan before 09:00 AM",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF014576),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.pink.shade100,
                        child: Image.asset(
                          'assets/boy.png',
                          width: 16,
                          height: 16,
                        ),
                      ),
                      const SizedBox(width: 6),
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.pink.shade100,
                        child: Image.asset(
                          'assets/man.png',
                          width: 16,
                          height: 16,
                        ),
                      ),
                      const SizedBox(width: 6),
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.pink.shade100,
                        child: Image.asset(
                          'assets/woman.png',
                          width: 16,
                          height: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "+4",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF014576),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Real-Time Date Bar
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _next7Days.length,
                itemBuilder: (context, index) {
                  final date = _next7Days[index];
                  final day = DateFormat('E').format(date);
                  final dateNum = DateFormat('d').format(date);
                  final isSelected = index == _selectedDateIndex;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDateIndex = index;
                        });
                      },
                      child: Container(
                        width: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF5E9BC8)
                              : Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4,
                              offset: const Offset(1, 2),
                              color: Colors.black12,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                day,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              Text(
                                dateNum,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "DASHBOARD",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF014576),

                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 10),

            const DashboardCard(title: "Snow Flakes Given"),
            const DashboardCard(title: "Snow Flakes Received"),
            const DashboardCard(title: "Foreign Country Opportunity"),
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
