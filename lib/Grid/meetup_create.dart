import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/Data/Repositories/meetuplist_repository.dart';
import 'package:snow_app/Data/models/meetup_list.dart';
import 'package:snow_app/Grid/SnowMeetupForm.dart';
import '../core/api_client.dart';

class MeetupListScreen extends StatefulWidget {
  const MeetupListScreen({super.key});

  @override
  State<MeetupListScreen> createState() => _MeetupListScreenState();
}

class _MeetupListScreenState extends State<MeetupListScreen> {
  late final MeetupListRepository _repo;
  late Future<MeetupListResponse> _futureMeetups;

  @override
  void initState() {
    super.initState();
    _repo = MeetupListRepository(ApiClient.create());
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _futureMeetups = _repo.fetchMeetups();
    });
  }

  Future<void> _navigateToAddScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SnowMeetupScreen()),
    );
    if (result == true) {
      _fetchData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Meetup created successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// ✅ Background Image with Gradient Overlay
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

        /// ✅ Foreground Scaffold
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Business Meetups',
              style: GoogleFonts.poppins(
                color: const Color(0xFF014576),
                fontWeight: FontWeight.w600,
                fontSize: 20,
                shadows: [
                  const Shadow(
                    blurRadius: 4,
                    color: Color.fromARGB(150, 200, 240, 255),
                    offset: Offset(1, 2),
                  ),
                ],
              ),
            ),
            iconTheme: const IconThemeData(color: Color(0xFF014576)),
          ),
          body: FutureBuilder<MeetupListResponse>(
            future: _futureMeetups,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error: ${snapshot.error}",
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.meetups.isEmpty) {
                return Center(
                  child: Text(
                    "No meetups found",
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                );
              }

              final meetups = snapshot.data!.meetups;

              return RefreshIndicator(
                onRefresh: () async => _fetchData(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: meetups.length,
                  itemBuilder: (context, index) {
                    final m = meetups[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.70),
                            const Color.fromARGB(255, 202, 232, 250),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF70A9EE).withOpacity(0.10),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFF70A9EE).withOpacity(0.18),
                          width: 1.2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF014576),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  m.description,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const Divider(height: 20),
                                _buildInfoRow(
                                  Icons.location_on,
                                  "${m.venueName}, ${m.venueCity}, ${m.venueCountry}",
                                ),
                                _buildInfoRow(
                                  Icons.date_range,
                                  "Date: ${m.date}",
                                ),
                                _buildInfoRow(
                                  Icons.people,
                                  "Capacity: ${m.capacity}",
                                ),
                                _buildInfoRow(
                                  Icons.payment,
                                  m.isPaid == true
                                      ? "Paid: ₹${m.price}"
                                      : "Free",
                                ),
                                const Divider(height: 20),
                                Text(
                                  "Contact:",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "${m.contactName} | ${m.contactEmail}\n${m.contactPhone}",
                                  style: GoogleFonts.poppins(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _navigateToAddScreen,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              "Add Meetup",
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            backgroundColor: const Color(0xFF014576),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // ✅ Rounded edges
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF014576), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
