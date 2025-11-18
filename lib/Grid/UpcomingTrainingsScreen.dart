import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/Data/Repositories/New%20Repositories/EXTRA%20FEATURE/traning_reg.dart';
import 'dart:ui';

import 'package:snow_app/Data/models/New Model/extra feature/traning_reg.dart';

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

  @override
  void initState() {
    super.initState();
    loadTrainings();
  }

  Future<void> loadTrainings() async {
    setState(() => isLoading = true);

    try {
      final response = await repo.fetchTrainings();
      trainings = response.data;
    } catch (e) {
      debugPrint("❌ TRAININGS FETCH ERROR: $e");
    }

    setState(() => isLoading = false);
  }

  /// Format date
  String _formatDate(DateTime? date) {
    if (date == null) return "N/A";
    return "${date.day}-${date.month}-${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background + gradient
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

        // Main UI
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'TRAININGS',
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
            iconTheme: const IconThemeData(color: Color(0xFF014576)),
          ),

          body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF014576)),
                )
              : trainings.isEmpty
              ? Center(
                  child: Text(
                    "No Trainings Found",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: trainings.length,
                  itemBuilder: (context, index) {
                    final training = trainings[index];

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 197, 219, 248),
                            Color(0xFFEAF5FC),
                            Color.fromARGB(255, 197, 219, 248),
                          ],
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: const Color(0xFF014576),
                              child: Text(
                                training.title.isNotEmpty
                                    ? training.title[0].toUpperCase()
                                    : "T",
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    training.title,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF014576),
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  // topic
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.topic,
                                        size: 16,
                                        color: Colors.black54,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          training.description,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 4),

                                  // date
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                        color: Colors.black45,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _formatDate(training.trainingDate),
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

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 1,
                                backgroundColor: Color(0xFF014576),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),


                              onPressed: () async {
                                final res = await repo.registerForTraining(
                                  training.id,
                                );

                                if (res["success"] == true) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Registered successfully",
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                child: Text(
                                  'Register',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
