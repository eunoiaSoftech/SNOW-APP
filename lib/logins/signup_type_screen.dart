import 'package:flutter/material.dart';
import 'package:snow_app/logins/sign_up.dart';
import 'package:snow_app/logins/signup_froms.dart/SnowNormalForm.dart';
import 'package:snow_app/logins/signup_froms.dart/SnowRealEstateForm.dart';
import 'package:snow_app/logins/signup_froms.dart/SnowYouthForm.dart';
import 'package:snow_app/logins/signup_froms.dart/VisitorForm.dart';


class SelectTypePage extends StatelessWidget {
  const SelectTypePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF5E9BC8);
    const double cardRadius = 20;

    final List<Map<String, dynamic>> options = [
      {'title': 'Elite Member', 'icon': Icons.star, 'page': const SignUpPage()},
      {'title': 'SnowYouth', 'icon': Icons.emoji_events, 'page': const SnowYouthFormPage()},
      {'title': 'SnowNormalPeople', 'icon': Icons.people, 'page': const SnowNormalFormPage()},
      {'title': 'SnowRealEstate', 'icon': Icons.apartment, 'page': const SnowRealEstateFormPage()},
      {'title': 'Visitor', 'icon': Icons.person_outline, 'page': const VisitorFormPage()},
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          SizedBox.expand(
            child: Image.asset('assets/bglogin.jpg', fit: BoxFit.cover),
          ),
          // Semi-transparent overlay
          // Container(color: Colors.black.withOpacity(0.4)),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    const Text(
                      'Select Membership Type',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please select your membership type.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ...options.map((option) {
                      return GestureDetector(
                        onTap: () {
                          if (option['page'] != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => option['page'],
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${option['title']} form coming soon!'),
                              ),
                            );
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(cardRadius),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 15,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: primaryColor.withOpacity(0.2),
                                child: Icon(
                                  option['icon'],
                                  color: primaryColor,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                option['title'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 18,
                                color: Colors.grey,
                              )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
