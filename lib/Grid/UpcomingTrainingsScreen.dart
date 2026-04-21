import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:snow_app/Data/Repositories/New%20Repositories/EXTRA%20FEATURE/traning_reg.dart';
import 'package:snow_app/Data/models/New Model/extra feature/traning_reg.dart';
import 'package:snow_app/Grid/traning_from.dart';

class UpcomingTrainingsScreen extends StatefulWidget {
  const UpcomingTrainingsScreen({super.key});

  @override
  State<UpcomingTrainingsScreen> createState() =>
      _UpcomingTrainingsScreenState();
}

class _UpcomingTrainingsScreenState extends State<UpcomingTrainingsScreen> {
  final repo = TrainingRepositoryNew();
  List<TrainingRecord> trainings = [];
  bool isLoading = true;

  // Primary branding color
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
      final response = await repo.fetchTrainings();
      if (mounted) {
        setState(() {
          trainings = response.data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      debugPrint("❌ TRAININGS FETCH ERROR: $e");
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
          'TRAINING PROGRAMS',
          style: GoogleFonts.poppins(
            color: Color(0xFF014576),
            fontWeight: FontWeight.w600,
            fontSize: 20,
            shadows: [
              Shadow(
                blurRadius: 4,
                color: Color.fromARGB(150, 200, 240, 255),
                offset: Offset(1, 2),
              ),
            ],
          ),
        ),
        iconTheme: IconThemeData(color: primaryDark),
        actions: [
          IconButton(
            onPressed: loadTrainings,
            icon: Icon(Icons.refresh_rounded, color: primaryDark),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Keep your original BG image and gradient container as is
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
                        Color(0xAA70A9EE),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Content
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
                      return _buildTrainingCard(trainings[index]);
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildTrainingCard(TrainingRecord training) {
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
                    // Date Badge (Proper UI Element)
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
                            training.trainingDate?.day.toString() ?? "??",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _getMonth(training.trainingDate),
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
                    // Title & Description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            training.title,
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: primaryDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            training.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Colors.black12),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Mode Tag
                    Row(
                      children: [
                        Icon(
                          Icons.video_camera_front_outlined,
                          size: 16,
                          color: primaryDark,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          training.mode.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: primaryDark.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    // Action Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryDark,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TrainingDetailsScreen(training: training),
                          ),
                        );
                      },
                      child: Text(
                        'Register Now',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note_outlined,
            size: 80,
            color: primaryDark.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "No Upcoming Trainings",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
