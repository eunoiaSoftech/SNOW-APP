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
          backgroundColor: Colors.white.withOpacity(0.95),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(backgroundImage: AssetImage(user['avatar']), radius: 40),
              const SizedBox(height: 12),
              Text(user['name'],
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.cake_outlined, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text("Age: ${user['age']} years old", style: GoogleFonts.poppins()),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.business_center_outlined, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text("Company: ${user['company']}", style: GoogleFonts.poppins()),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text("Location: ${user['location']}", style: GoogleFonts.poppins()),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500, color: const Color(0xFF5E9BC8))),
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("$name has been approved!", style: GoogleFonts.poppins()),
      backgroundColor: Colors.green.shade600,
    ));
  }

  void _deleteUser(String name) {
    setState(() {
      pendingUsers.removeWhere((user) => user['name'] == name);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("$name has been deleted!", style: GoogleFonts.poppins()),
      backgroundColor: Colors.red.shade600,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image + Gradient
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
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ],
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              "NOTIFICATIONS",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF014576),
                shadows: [
                  Shadow(
                    blurRadius: 4,
                    color: Color.fromARGB(150, 200, 240, 255),
                    offset: Offset(1, 2),
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Color(0xFF014576)),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               
                Expanded(
                  child: pendingUsers.isEmpty
                      ? Center(
                          child: Text(
                            "No pending connections",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: pendingUsers.length,
                          itemBuilder: (context, index) {
                            final user = pendingUsers[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                             decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Color(0xFFEAF5FC), Color(0xFFD8E7FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
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
                                          child: Text(user['name'],
                                              style: GoogleFonts.poppins(fontSize: 16)),
                                        ),
                                        TextButton(
                                          onPressed: () => _showUserDetails(context, user),
                                          child: Text("View",
                                              style: GoogleFonts.poppins(
                                                color: Color(0xFF5E9BC8),
                                                fontWeight: FontWeight.w500,
                                              )),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => _approveUser(user['name']),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 18),
                                            backgroundColor: const Color(0xFF6EC76E),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: Text("APPROVE",
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white)),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => _deleteUser(user['name']),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 20),
                                            backgroundColor: const Color(0xFFE57373),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: Text("DELETE",
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
