import 'package:flutter/material.dart';
import 'package:snow_app/home/dashboard.dart';
import 'package:snow_app/logins/under_maintenance_screen.dart';
import 'package:snow_app/logins/update_required_screen.dart';
import 'package:snow_fall_animation/snow_fall_animation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snow_app/onboarding_screen.dart';
import 'package:snow_app/Admin Home Page/homewapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    navigateBasedOnLogin();
  }

  Future<void> navigateBasedOnLogin() async {
    final prefs = await SharedPreferences.getInstance();
 
    // 🔹 APP STATE FLAGS (temporary till API comes)
    final bool isUnderMaintenance =
        prefs.getBool('isUnderMaintenance') ?? false;

    final bool isForceUpdate = prefs.getBool('isForceUpdate') ?? false;

    // 🔹 LOGIN FLAGS
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final bool isAdmin = prefs.getBool('isAdmin') ?? false;

    debugPrint('🟡 SPLASH: Checking app state...');
    debugPrint('🟡 isUnderMaintenance = $isUnderMaintenance');
    debugPrint('🟡 isForceUpdate = $isForceUpdate');
    debugPrint('🟡 isLoggedIn = $isLoggedIn');
    debugPrint('🟡 isAdmin = $isAdmin');

    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // 🚧 1️⃣ UNDER MAINTENANCE
    if (isUnderMaintenance) {
      debugPrint('➡️ Navigating to UNDER MAINTENANCE screen');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UnderMaintenanceScreen()),
      );
      return;
    }

    // 🔄 2️⃣ FORCE UPDATE
    if (isForceUpdate) {
      debugPrint('➡️ Navigating to UPDATE REQUIRED screen');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UpdateRequiredScreen()),
      );
      return;
    }

    // 🔐 3️⃣ NORMAL LOGIN FLOW
    if (isLoggedIn) {
      if (isAdmin) {
        debugPrint('➡️ Navigating to ADMIN HOME');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainHome(role: 'admin')),
        );
      } else {
        debugPrint('➡️ Navigating to USER DASHBOARD');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SnowDashboard()),
        );
      }
    } else {
      debugPrint('➡️ Navigating to ONBOARDING');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  // Future<void> navigateBasedOnLogin() async {
  //   final prefs = await SharedPreferences.getInstance();

  //   // 🔹 APP STATE FLAGS (from API later)
  //   final bool isUnderMaintenance =
  //       prefs.getBool('isUnderMaintenance') ?? false;

  //   final bool isForceUpdate =
  //       prefs.getBool('isForceUpdate') ?? false;

  //   // 🔹 AUTH FLAGS
  //   final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  //   final bool isAdmin = prefs.getBool('isAdmin') ?? false;

  //   await Future.delayed(const Duration(seconds: 3));

  //   if (!mounted) return;

  //   // 🚧 1️⃣ UNDER MAINTENANCE (TOP PRIORITY)
  //   if (isUnderMaintenance) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (_) => const UnderMaintenanceScreen(),
  //       ),
  //     );
  //     return;
  //   }

  //   // 🔄 2️⃣ FORCE UPDATE
  //   if (isForceUpdate) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (_) => const UpdateRequiredScreen(),
  //       ),
  //     );
  //     return;
  //   }

  //   // 🔐 3️⃣ NORMAL LOGIN FLOW
  //   if (isLoggedIn) {
  //     if (isAdmin) {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //           builder: (_) => const MainHome(role: 'admin'),
  //         ),
  //       );
  //     } else {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //           builder: (_) => const SnowDashboard(),
  //         ),
  //       );
  //     }
  //   } else {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (_) => const OnboardingScreen(),
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/onbordingbg.jpg', fit: BoxFit.cover),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xAA97DCEB),
                        Color(0xAA5E9BC8),
                        Colors.white,
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
          const SnowFallAnimation(
            config: SnowfallConfig(
              numberOfSnowflakes: 100,
              maxSnowflakeSize: 7,
              minSnowflakeSize: 3,
              windForce: 0.5,
              speed: 2.0,
            ),
          ),
          Center(
            child: Image.asset(
              'assets/logo.png',
              width: 300,
              height: 280,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
