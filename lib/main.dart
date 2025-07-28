import 'package:flutter/material.dart';
import 'package:snow_app/spalsh_screen.dart';

void main() {
  
  runApp(const SnowApp());
}


class SnowApp extends StatelessWidget {
  const SnowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}