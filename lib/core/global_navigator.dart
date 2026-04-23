import 'package:flutter/material.dart';
import 'package:snow_app/logins/login.dart';
import 'package:snow_app/core/app_toast.dart';

class GlobalNavigator {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static void logoutUser({String? message}) {
    final context = navigatorKey.currentContext;

    // ✅ Show toast instead of snackbar
    if (context != null && message != null) {
      context.showToast(message);
    }

    navigatorKey.currentState?.pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginPage(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (route) => false,
    );
  }
}