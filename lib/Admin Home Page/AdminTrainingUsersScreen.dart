import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:snow_app/Data/Repositories/New%20Repositories/EXTRA%20FEATURE/traning_reg.dart';
import 'package:snow_app/Data/models/admin_training_registration_model.dart';

class AdminTrainingUsersScreen extends StatefulWidget {
  final int trainingId;

  const AdminTrainingUsersScreen({super.key, required this.trainingId});

  @override
  State<AdminTrainingUsersScreen> createState() =>
      _AdminTrainingUsersScreenState();
}

class _AdminTrainingUsersScreenState extends State<AdminTrainingUsersScreen> {
  final repo = TrainingRepositoryNew();
  List<AdminTrainingRegistrationModel> users = [];
  bool isLoading = true;

  final Color primaryDark = const Color(0xFF014576);

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final res = await repo.getRegisteredUsers(widget.trainingId);
      if (mounted) {
        setState(() {
          users = res.users;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      _showSnackBar(e.toString().replaceAll("Exception: ", ""), Colors.red);
    }
  }

  Future<void> markAttendance(int id) async {
    try {
      final msg = await repo.markAttendance(id);
      _showSnackBar(msg, Colors.green);
      loadUsers(); // Refresh the list
    } catch (e) {
      _showSnackBar(e.toString().replaceAll("Exception: ", ""), Colors.red);
    }
  }

Future<void> confirmMark(AdminTrainingRegistrationModel u) async {
    final confirm = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.4), // Dims the background
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Material(
                  color: Colors.white.withOpacity(0.7),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Alert Icon
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: primaryDark.withOpacity(0.1),
                          child: Icon(Icons.how_to_reg_rounded, 
                                     color: primaryDark, size: 30),
                        ),
                        const SizedBox(height: 20),
                        
                        // Title
                        Text(
                          "Confirm Attendance",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Content
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.poppins(color: Colors.black87, fontSize: 14),
                            children: [
                              const TextSpan(text: "Are you sure you want to mark "),
                              TextSpan(
                                text: u.name ?? "this user",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: " as attended?\n\n"),
                              TextSpan(
                                text: "This action cannot be undone.",
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        
                        // Actions
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(
                                  "Cancel",
                                  style: GoogleFonts.poppins(color: Colors.black54),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryDark,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  "Confirm",
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
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
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: child,
        );
      },
    );

    if (confirm == true) {
      markAttendance(u.id);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String safe(String? value) =>
      (value != null && value.isNotEmpty) ? value : "N/A";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryDark),
        title: Text(
          "REGISTERED USERS",
          style: GoogleFonts.poppins(
            color: primaryDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1.1,
          ),
        ),
        actions: [
          IconButton(
            onPressed: loadUsers,
            icon: Icon(Icons.sync_rounded, color: primaryDark),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset('assets/bghome.jpg', fit: BoxFit.cover),
          ),
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.5),
                    const Color(0xFF97DCEB).withOpacity(0.6),
                    const Color(0xFF70A9EE).withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ),

          // Content
          isLoading
              ? Center(child: CircularProgressIndicator(color: primaryDark))
              : users.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: loadUsers,
                  color: primaryDark,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 110, 16, 100),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return _buildUserCard(users[index]);
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildUserCard(AdminTrainingRegistrationModel u) {
    bool isAttended = u.attendanceStatus == "ATTENDED";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                // User Avatar Placeholder
                CircleAvatar(
                  radius: 25,
                  backgroundColor: primaryDark.withOpacity(0.1),
                  child: Icon(Icons.person_outline, color: primaryDark),
                ),
                const SizedBox(width: 15),
                // User Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        safe(u.name),
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: primaryDark,
                        ),
                      ),
                      Text(
                        safe(u.email),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isAttended
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          u.attendanceStatus ?? "PENDING",
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isAttended ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Action
                isAttended
                    ? const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 28,
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryDark,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        // onPressed: () => markAttendance(u.id),
                        onPressed: () => confirmMark(u),
                        child: Text(
                          "Mark",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: primaryDark.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "No users registered yet",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
