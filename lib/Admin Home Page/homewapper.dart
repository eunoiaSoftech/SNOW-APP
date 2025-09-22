import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:snow_app/Admin%20Home%20Page/admin_home.dart';
import 'package:snow_app/home/dashboard.dart'; 
import 'package:snow_app/Grid/grid.dart';
import 'package:snow_app/Grid/profile.dart';

class MainHome extends StatefulWidget {
  final String role; // 'admin' or 'user'
  const MainHome({super.key, required this.role});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Define screens based on role
    final pages = widget.role == 'admin'
        ? [
            const AdminHomeScreen(), // Admin Dashboard
            const GradientGridScreen(), 
            const ProfileScreen(),
          ]
        : [
            const SnowDashboard(), // User Dashboard
            const GradientGridScreen(),
            const ProfileScreen(),
          ];

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,

      body: Stack(
        children: [
          // Background
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

          // Main content
          SafeArea(child: pages[_selectedIndex]),

          // Bottom Navigation Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: CurvedNavigationBar(
              index: _selectedIndex,
              height: 60.0,
              backgroundColor: Colors.transparent,
              color: const Color.fromARGB(255, 184, 223, 247),
              buttonBackgroundColor: const Color(0xFF5E9BC8),
              animationDuration: const Duration(milliseconds: 300),
              animationCurve: Curves.easeInOut,
              items: const <Widget>[
                Icon(Icons.home, size: 30, color: Colors.white),
                Icon(Icons.grid_view, size: 30, color: Colors.white),
                Icon(Icons.person, size: 30, color: Colors.white),
              ],
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
