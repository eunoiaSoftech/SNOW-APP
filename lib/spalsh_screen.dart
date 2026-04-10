import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:snow_app/Data/models/New%20Model/APP%20SETTING/app_settings_repository.dart';
import 'package:snow_app/core/secure_storage.dart';
import 'package:snow_app/home/dashboard.dart';
import 'package:snow_app/logins/under_maintenance_screen.dart';
import 'package:snow_app/logins/update_required_screen.dart';
import 'package:snow_fall_animation/snow_fall_animation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snow_app/onboarding_screen.dart';
import 'package:snow_app/Admin Home Page/homewapper.dart';
import 'package:snow_app/core/module_access_service.dart';
import 'package:snow_app/core/result.dart';
import 'package:snow_app/Data/Repositories/profile_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AppSettingsRepository _settingsRepo = AppSettingsRepository();
  final ProfileRepository _profileRepo = ProfileRepository();
  final ModuleAccessService _moduleAccessService = ModuleAccessService();

  @override
  void initState() {
    super.initState();
    navigateBasedOnLogin();
  }

  /// Compares two version strings (e.g., "1.0.0" vs "1.2.1")
  /// Returns -1 if version1 < version2, 0 if equal, 1 if version1 > version2
  int _compareVersions(String version1, String version2) {
    final parts1 = version1
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();
    final parts2 = version2
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();

    // Normalize lengths by padding with zeros
    final maxLength = parts1.length > parts2.length
        ? parts1.length
        : parts2.length;
    while (parts1.length < maxLength) parts1.add(0);
    while (parts2.length < maxLength) parts2.add(0);

    for (int i = 0; i < maxLength; i++) {
      if (parts1[i] < parts2[i]) return -1;
      if (parts1[i] > parts2[i]) return 1;
    }
    return 0;
  }

  Future<void> navigateBasedOnLogin() async {
    final prefs = await SharedPreferences.getInstance();

    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final bool isAdmin = prefs.getBool('isAdmin') ?? false;

    debugPrint('🟡 SPLASH: Starting app settings check');

    try {
      final platform = Platform.isAndroid ? 'android' : 'ios';

      // 🔥 Prefetch profile on app open (logged-in only).
      // This warms up module access + profile data before user lands.
      Future<void> profileWarmup = Future.value();
      if (isLoggedIn) {
        profileWarmup = _warmupProfile();
      }

      /// 🔐 Fetch app settings WITH TIMEOUT (CRITICAL FIX)
      final settings = await _settingsRepo
          .fetchAppSettings(platform)
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () {
              debugPrint('⏱️ App settings API timeout');
              return null;
            },
          );

      // App version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      debugPrint('🟢 Current app version = $currentVersion');

      // Keep splash visible for UX
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;

      // Don't block navigation for too long; best-effort warmup.
      await profileWarmup.timeout(
        const Duration(seconds: 6),
        onTimeout: () {
          debugPrint('⏱️ Profile warmup timeout');
          return;
        },
      );

      /// 🛑 SAFETY NET — If settings API FAILED or returned null
      if (settings == null) {
        debugPrint('⚠️ Settings NULL — continuing normal flow');

        if (isLoggedIn) {
          if (isAdmin) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainHome(role: 'admin')),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SnowDashboard()),
            );
          }
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          );
        }
        return;
      }

      debugPrint('🟢 SETTINGS RECEIVED');
      debugPrint('🟢 maintenanceMode = ${settings.maintenanceMode}');
      debugPrint('🟢 forceUpdate = ${settings.forceUpdate}');
      debugPrint('🟢 minRequiredVersion = ${settings.minRequiredVersion}');
      debugPrint('🟢 forceLogout = ${settings.forceLogout}');

      /// 🚧 1️⃣ UNDER MAINTENANCE
      if (settings.maintenanceMode == true) {
        debugPrint('➡️ Navigating to UNDER MAINTENANCE');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => UnderMaintenanceScreen(
              message:
                  settings.maintenanceMessage ??
                  "The app is under maintenance.",
            ),
          ),
        );
        return;
      }

      /// 🔄 2️⃣ FORCE UPDATE
      if (settings.forceUpdate == true) {
        final minRequiredVersion = settings.minRequiredVersion ?? '';

        if (minRequiredVersion.isNotEmpty) {
          final versionComparison = _compareVersions(
            currentVersion,
            minRequiredVersion,
          );

          debugPrint(
            '🟢 Version check: $currentVersion vs $minRequiredVersion = $versionComparison',
          );

          if (versionComparison < 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => UpdateRequiredScreen(
                  message:
                      settings.updateMessage ??
                      "Please update the app to continue.",
                ),
              ),
            );
            return;
          }
        } else {
          // forceUpdate true but no version info → still update
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => UpdateRequiredScreen(
                message:
                    settings.updateMessage ??
                    "Please update the app to continue.",
              ),
            ),
          );
          return;
        }
      }

      /// 🚪 3️⃣ FORCE LOGOUT
      if (settings.forceLogout == true) {
        debugPrint('➡️ Force logout triggered');

        final message = settings.updateMessage?.isNotEmpty == true
            ? settings.updateMessage!
            : "Session expired. Please login again.";

        final storage = SecureStorageService();

        await prefs.clear();
        await storage.clearToken();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );

        await Future.delayed(const Duration(seconds: 2));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
        return;
      }

      /// 🔐 4️⃣ NORMAL FLOW
      if (isLoggedIn) {
        if (isAdmin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainHome(role: 'admin')),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SnowDashboard()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    } catch (e) {
      /// ❌ ABSOLUTE FALLBACK — NEVER STUCK
      debugPrint('❌ Splash error: $e');

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  Future<void> _warmupProfile() async {
    try {
      final res = await _profileRepo.fetchProfile();

      switch (res) {
        case Ok(value: final profile):
          _moduleAccessService.updateModules(profile.modules);
          debugPrint('✅ Profile warmed up. Modules: ${profile.modules.length}');
          break;
        case Err(message: final msg, code: final code):
          debugPrint('⚠️ Profile warmup failed ($code): $msg');
          break;
      }
    } catch (e) {
      debugPrint('⚠️ Profile warmup error: $e');
    }
  }

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
