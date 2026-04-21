import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/Admin%20Home%20Page/AdminCreateTrainingScreen.dart';
import 'dart:ui';
import 'package:snow_app/Data/Repositories/New%20Repositories/EXTRA%20FEATURE/traning_reg.dart';
import 'package:snow_app/Data/models/New Model/extra feature/traning_reg.dart';
import 'AdminTrainingUsersScreen.dart';

class AdminTrainingListScreen extends StatefulWidget {
  const AdminTrainingListScreen({super.key});

  @override
  State<AdminTrainingListScreen> createState() =>
      _AdminTrainingListScreenState();
}

class _AdminTrainingListScreenState extends State<AdminTrainingListScreen> {
  final repo = TrainingRepositoryNew();
  List<TrainingRecord> trainings = [];
  bool isLoading = true;

  final Color primaryDark = const Color(0xFF014576);

  @override
  void initState() {
    super.initState();
    loadTrainings();
  }

  Future<void> loadTrainings() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final res = await repo.fetchTrainings();
      if (mounted) {
        setState(() {
          trainings = res.data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      debugPrint("❌ ADMIN FETCH ERROR: $e");
    }
  }

  String _getMonth(DateTime? date) {
    if (date == null) return "N/A";
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return months[date.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'ADMIN: TRAININGS',
          style: GoogleFonts.poppins(
            color: primaryDark,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 18,
          ),
        ),
        iconTheme: IconThemeData(color: primaryDark),
        actions: [
          // IconButton(
          //   onPressed: loadTrainings,
          //   icon: Icon(Icons.refresh_rounded, color: primaryDark),
          // ),

          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminCreateTrainingScreen(),
                  ),
                ).then((_) => loadTrainings());
              },
              icon: const Icon(Icons.add),
              label: const Text("Create"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryDark,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Keeping consistent background
          Positioned.fill(
            child: Image.asset('assets/bghome.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.4),
                    const Color(0xFF97DCEB).withOpacity(0.6),
                    const Color(0xFF70A9EE).withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ),

          // Main Admin Content
          isLoading
              ? Center(child: CircularProgressIndicator(color: primaryDark))
              : trainings.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: loadTrainings,
                  color: primaryDark,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 110, 16, 100),
                    itemCount: trainings.length,
                    itemBuilder: (context, index) {
                      return _buildAdminTrainingCard(trainings[index]);
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildAdminTrainingCard(TrainingRecord t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminTrainingUsersScreen(trainingId: t.id),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Badge (Consistent with Upcoming Screen)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: primaryDark,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            Text(
                              t.trainingDate?.day.toString() ?? "??",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _getMonth(t.trainingDate),
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Training Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.title,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  t.city,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: primaryDark),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1, color: Colors.black12),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Mode/Category Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryDark.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "MODE: ${t.mode.toUpperCase()}",
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: primaryDark,
                          ),
                        ),
                      ),
                      // Admin Info
                      Text(
                        "Click to view registrations",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: Colors.black45,
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 80,
            color: primaryDark.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "No Active Training Records",
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
