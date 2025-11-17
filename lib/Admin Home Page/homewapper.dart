import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:snow_app/Admin Home Page/admin_home.dart';
import 'package:snow_app/logins/login.dart';

class MainHome extends StatefulWidget {
  final String role; // 'admin' or 'user'
  const MainHome({super.key, required this.role});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  double _marginTop = 0;
  double _opacity = 1;

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.role == "admin";

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,

      body: Stack(
        children: [
          _buildBackground(),

          // ALWAYS SHOW HOME—Admin or User
          SafeArea(
            child: isAdmin ? const AdminHomeScreen() : const AdminHomeScreen(),
          ),

          // 🔥 BOTTOM LOGOUT ONLY FOR ADMIN
          if (isAdmin)
            Align(
              alignment: Alignment.bottomCenter,
              child: CurvedNavigationBar(
                index: 0,
                height: 60.0,
                backgroundColor: Colors.transparent,
                color: const Color.fromARGB(255, 184, 223, 247),
                buttonBackgroundColor: const Color(0xFF5E9BC8),
                animationDuration: const Duration(milliseconds: 300),
                animationCurve: Curves.easeInOut,
                items: const [
                  Icon(Icons.logout, size: 32, color: Colors.white),
                ],
                onTap: (index) {
                  _confirmLogout();
                },
              ),
            ),
        ],
      ),
    );
  }

  // ---------- Background Widget ----------
  Widget _buildBackground() {
    return Positioned.fill(
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
    );
  }

  // ---------- LOGOUT POPUP ----------
  void _confirmLogout() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Logout",
      transitionDuration: const Duration(milliseconds: 400),

      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },

      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedValue = Curves.easeInOut.transform(animation.value);
        return Transform.scale(
          scale: 0.95 + curvedValue * 0.05,
          child: Opacity(
            opacity: animation.value,

            // ⭐ THIS LINE FIXES THE YELLOW HIGHLIGHT
            child: Material(
              type: MaterialType.transparency,

              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.symmetric(horizontal: 28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.white,
                        Color(0xFFE3F3FE),
                        Color(0xFFBDE2FC),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5E9BC8).withOpacity(0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(
                      color: const Color.fromARGB(255, 179, 220, 255),
                      width: 2,
                    ),
                  ),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("❄️", style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 10),

                      Text(
                        "Logout from SnowApp?",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: const Color(0xFF014576),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Are you sure you want to log out?\nWe'll miss you in the snow! ☃️",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.blueGrey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.poppins(
                                color: Colors.blueGrey,
                              ),
                            ),
                          ),
                          const SizedBox(width: 18),

                          ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);

                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool("isLoggedIn", false);
                              await prefs.remove("isAdmin");
                              await prefs.remove("userRole");

                              if (!mounted) return;

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
                                ),
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF014576),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              "Logout",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
