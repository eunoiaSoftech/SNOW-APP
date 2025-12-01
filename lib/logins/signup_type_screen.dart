import 'package:flutter/material.dart';
import 'package:snow_app/logins/sign_up.dart';
import 'package:snow_app/logins/signup_froms.dart/SnowRealEstateForm.dart';
import 'package:snow_app/logins/signup_froms.dart/VisitorForm.dart';

class SelectTypePage extends StatelessWidget {
  const SelectTypePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF5E9BC8);
    const double cardRadius = 20;

    final List<Map<String, dynamic>> options = [
      {'title': 'Elite Member', 'icon': Icons.star, 'page': const SignUpPage()},
      {'title': 'Visitor', 'icon': Icons.person_outline, 'page': const VisitorFormPage()},
      {'title': 'Snow Real Estate', 'icon': Icons.business, 'page': const SnowRealEstateFormPage()},
    ];

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset('assets/bglogin.jpg', fit: BoxFit.cover),
          ),
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
                      'Choose the sign-up flow that matches your role.',
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => option['page'] as Widget,
                            ),
                          );
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
                                  option['icon'] as IconData,
                                  color: primaryColor,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                option['title'] as String,
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
