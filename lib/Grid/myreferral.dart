import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:snow_app/Data/Repositories/referrals_repository.dart';
import 'package:snow_app/Grid/sbog.dart';
import '../core/api_client.dart';

class MyReferralsScreen extends StatefulWidget {
  @override
  _MyReferralsScreenState createState() => _MyReferralsScreenState();
}

class _MyReferralsScreenState extends State<MyReferralsScreen> {
  final repository = ReferralsRepository(ApiClient.create());
  bool _isLoading = true;
  List referrals = [];

  @override
  void initState() {
    super.initState();
    _fetchReferrals();
  }

  void _fetchReferrals() async {
    try {
      final response = await repository.getMyReferrals();
      setState(() {
        referrals = response.referrals ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to fetch referrals: $e')));
    }
  }

  String formatDateTime(String dateTime) {
    try {
      DateTime dt = DateTime.parse(dateTime);
      return DateFormat('dd MMM yyyy • hh:mm a').format(dt);
    } catch (e) {
      return dateTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ✅ Background
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

        // ✅ Foreground
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'REFERRALS',
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
            iconTheme: IconThemeData(color: Color(0xFF014576)),
          ),
          body: _isLoading
              ? Center(child: CircularProgressIndicator())
              : referrals.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "NO REFERRALS FOUND",
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF014576),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecordSBOGScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "CREATE SBOG",
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                   

                      // ✅ Referrals List
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: referrals.length,
                        itemBuilder: (context, index) {
                          final referral = referrals[index];

                          return Container(
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white.withOpacity(0.20),
                            ),
                            child: ClipRRect(
                              
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              referral.leadName.isNotEmpty
                                                  ? referral.leadName
                                                        .toUpperCase()
                                                  : 'NO NAME',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withOpacity(
                                                0.5,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              referral.status.isNotEmpty
                                                  ? referral.status
                                                        .toUpperCase()
                                                  : 'PENDING',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 12,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      if (referral.message.isNotEmpty) ...[
                                        Text(
                                          referral.message,
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                      ],
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: Colors.white70,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            referral.createdAt.isNotEmpty
                                                ? formatDateTime(
                                                    referral.createdAt,
                                                  )
                                                : '-',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 14),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF014576),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    RecordSBOGScreen(
                                                      
                                                    ),
                                              ),
                                            );
                                            _fetchReferrals(); // Refresh list after coming back
                                          },
                                          child: Text(
                                            "CREATE SBOG",
                                            style: GoogleFonts.montserrat(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
