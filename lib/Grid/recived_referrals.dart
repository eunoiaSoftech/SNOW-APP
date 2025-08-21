import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/Grid/RecordSFGScreen.dart';
import '../Data/Repositories/referrals_repository.dart';
import '../core/api_client.dart';
import '../Data/models/referral_model.dart';

class ReceivedReferralsScreen extends StatefulWidget {
  const ReceivedReferralsScreen({super.key});

  @override
  State<ReceivedReferralsScreen> createState() =>
      _ReceivedReferralsScreenState();
}

class _ReceivedReferralsScreenState extends State<ReceivedReferralsScreen> {
  final repo = ReferralsRepository(ApiClient.create());
  List<Referral> _referrals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReferrals();
  }

  Future<void> _fetchReferrals() async {
    setState(() => _isLoading = true);
    try {
      _referrals = await repo.getReceivedReferrals();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to fetch referrals: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget buildStatusBadge(String status) {
    final color = status == 'successful' ? Colors.green : Colors.orange;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.poppins(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Received Referrals',
              style: GoogleFonts.poppins(
                color: const Color(0xFF014576),
                fontWeight: FontWeight.w600,
                fontSize: 22,
              ),
            ),
            iconTheme: const IconThemeData(color: Color(0xFF014576)),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _referrals.isEmpty
              ? const Center(child: Text('No referrals found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _referrals.length,
                  itemBuilder: (context, index) {
                    final referral = _referrals[index];
                    return GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RecordSFGScreen(leadId: int.parse(referral.id)),
                          ),
                        );
                        if (result == true) _fetchReferrals();
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.70),
                              Color.fromARGB(255, 202, 232, 250),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF70A9EE).withOpacity(0.10),
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ],
                          border: Border.all(
                            color: Color(0xFF70A9EE).withOpacity(0.18),
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
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.person,
                                              color: Color(0xFF014576),
                                              size: 22,
                                            ),
                                            SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                referral.leadName,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF014576),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      buildStatusBadge(referral.status),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.message_outlined,
                                        color: Color(0xFF5E9BC8),
                                        size: 17,
                                      ),
                                      SizedBox(width: 7),
                                      Expanded(
                                        child: Text(
                                          referral.message.isNotEmpty
                                              ? referral.message
                                              : 'No message provided',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Color(0xFF2D395A),
                                            letterSpacing: 0.05,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 15,
                                        color: Colors.blueGrey[400],
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        referral.createdAt,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Color(0xFF5E9BC8),
                                          fontWeight: FontWeight.w500,
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
                  },
                ),
        ),
      ],
    );
  }
}
