import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminApprovalScreen extends StatefulWidget {
  const AdminApprovalScreen({super.key});

  @override
  State<AdminApprovalScreen> createState() => _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends State<AdminApprovalScreen> {
  List<Map<String, dynamic>> pendingUsers = [
    {
      'name': 'Pravin Pawar',
      'age': 28,
      'company': 'SnowTech Pvt Ltd',
      'location': 'Mumbai, India',
      'avatar': 'assets/boy.png',
    },
    {
      'name': 'Shweta Vispute',
      'age': 25,
      'company': 'Winter Corp',
      'location': 'Pune, India',
      'avatar': 'assets/woman.png',
    },
  ];

  void _showUserDetails(BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(user['avatar']),
                radius: 40,
              ),
              const SizedBox(height: 12),
              Text(
                user['name'],
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Age
              Row(
                children: [
                  const Icon(Icons.cake_outlined, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(color: Colors.black),
                        children: [
                          const TextSpan(
                            text: 'Age: ',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(text: '${user['age']} years old'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Company
              Row(
                children: [
                  const Icon(
                    Icons.business_center_outlined,
                    size: 20,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(color: Colors.black),
                        children: [
                          const TextSpan(
                            text: 'Company: ',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(text: user['company']),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Location
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 20,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(color: Colors.black),
                        children: [
                          const TextSpan(
                            text: 'Location: ',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(text: user['location']),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Close",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF5E9BC8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _approveUser(String name) {
    setState(() {
      pendingUsers.removeWhere((user) => user['name'] == name);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$name has been approved!", style: GoogleFonts.poppins()),
        backgroundColor: Colors.green.shade600,
      ),
    );
  }

  void _deleteUser(String name) {
    setState(() {
      pendingUsers.removeWhere((user) => user['name'] == name);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$name has been deleted!", style: GoogleFonts.poppins()),
        backgroundColor: Colors.red.shade600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FC),
      appBar: AppBar(
        title: Text("Notifications", style: GoogleFonts.poppins()),
        centerTitle: true,
        backgroundColor: const Color(0xFF5E9BC8),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "New Connection",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5E9BC8),
              ),
            ),
            const SizedBox(height: 10),

            // User List
            ...pendingUsers.map(
              (user) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16.0,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundImage: AssetImage(user['avatar']),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                user['name'],
                                style: GoogleFonts.poppins(fontSize: 16),
                              ),
                            ),
                            TextButton(
                              onPressed: () => _showUserDetails(context, user),
                              child: Text(
                                "View",
                                style: GoogleFonts.poppins(
                                  color: Color(0xFF5E9BC8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () => _approveUser(user['name']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade400,
                              ),
                              child: Text(
                                "APPROVE",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => _deleteUser(user['name']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade400,
                              ),
                              child: Text(
                                "DELETE",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
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

            if (pendingUsers.isEmpty)
              Center(
                child: Text(
                  "No pending connections",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
