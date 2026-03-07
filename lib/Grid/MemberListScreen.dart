import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for Clipboard
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/Data/Repositories/DirectoryMemberRepository.dart';
import 'package:snow_app/Data/Repositories/New%20Repositories/location_repo.dart';
import 'package:snow_app/Data/models/New%20Model/location_data123.dart';
import 'package:snow_app/core/result.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final DirectoryMemberRepository repo = DirectoryMemberRepository();
  final LocationRepository locationRepo = LocationRepository();

  bool loading = true;
  List members = [];
  LocationData? locationData;

  @override
  void initState() {
    super.initState();
    loadMembers();
  }

  Future<void> loadMembers() async {
    try {
      final data = await repo.fetchMembers();
      final locationResult = await locationRepo.fetchLocationData();

      if (locationResult is Ok<LocationData>) {
        locationData = locationResult.value;
      }

      setState(() {
        members = data;
      });
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      loading = false;
    });
  }

  String getCountry(int? id) {
    if (locationData == null || id == null) return "";
    final c = locationData!.countries.firstWhere(
      (e) => e.id == id,
      orElse: () => Country(id: 0, name: "", code: "", zones: []),
    );
    return c.name;
  }

  String getZone(int? id) {
    if (locationData == null || id == null) return "";
    for (final c in locationData!.countries) {
      for (final z in c.zones) {
        if (z.id == id) return z.name;
      }
    }
    return "";
  }

  String getState(int? id) {
    if (locationData == null || id == null) return "";
    for (final c in locationData!.countries) {
      for (final z in c.zones) {
        for (final s in z.states) {
          if (s.id == id) return s.name;
        }
      }
    }
    return "";
  }

  String getCity(int? id) {
    if (locationData == null || id == null) return "";
    for (final c in locationData!.countries) {
      for (final z in c.zones) {
        for (final s in z.states) {
          for (final city in s.cities) {
            if (city.id == id) return city.name;
          }
        }
      }
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
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
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF014576)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        "Members",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF014576),
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Dynamic Member Count Chip
                      if (!loading)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF014576).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF014576).withOpacity(0.2)),
                          ),
                          child: Text(
                            "${members.length} Total",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF014576),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.45),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: loading
                        ? const Center(child: CircularProgressIndicator())
                        : RefreshIndicator(
                            onRefresh: loadMembers,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              physics: const BouncingScrollPhysics(),
                              itemCount: members.length,
                              itemBuilder: (context, index) {
                                final m = members[index];
                                final data = m["data"] ?? {};
                                final user = m["user"] ?? {};

                                final country = getCountry(data["country"]);
                                final zone = getZone(data["zone"]);
                                final state = getState(data["state"]);
                                final city = getCity(data["city"]);

                                List<String> locParts = [city, state, zone, country]
                                    .where((s) => s.isNotEmpty)
                                    .toList();
                                final locationString = locParts.join(", ");

                                return _MemberCard(
                                  name: data["full_name"] ?? user["display_name"] ?? "",
                                  email: data["email"] ?? user["email"] ?? "",
                                  contact: data["contact"] ?? "",
                                  business: data["business_name"] ?? "",
                                  category: data["business_category"] ?? "",
                                  description: data["company_description"] ?? "",
                                  linkedin: data["linkedin_id"] ?? "",
                                  facebook: data["facebook_id"] ?? "",
                                  instagram: data["instagram_id"] ?? "",
                                  location: locationString,
                                );
                              },
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final String name, email, contact, business, category, description, linkedin, facebook, instagram, location;

  const _MemberCard({
    required this.name,
    required this.email,
    required this.contact,
    required this.business,
    required this.category,
    required this.description,
    required this.linkedin,
    required this.facebook,
    required this.instagram,
    required this.location,
  });

  void _copyToClipboard(BuildContext context, String text, String label) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$label copied to clipboard!"),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF2E4A64);
    const accentColor = Color(0xFF5E9BC8);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.9),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: accentColor.withOpacity(0.15),
                  child: const Icon(Icons.person, color: accentColor, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      Text(
                        business,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow(Icons.email_outlined, email),
                _infoRow(Icons.phone_android_rounded, contact),
                _infoRow(Icons.category_outlined, category),
                if (location.isNotEmpty) _infoRow(Icons.location_on_outlined, location),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    "About Work:",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                ],
                if (linkedin.isNotEmpty || facebook.isNotEmpty || instagram.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    "Social Profiles (Tap to copy):",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (linkedin.isNotEmpty) _linkRow(context, Icons.link, linkedin, "LinkedIn"),
                  if (facebook.isNotEmpty) _linkRow(context, Icons.facebook, facebook, "Facebook"),
                  if (instagram.isNotEmpty) _linkRow(context, Icons.camera_alt_outlined, instagram, "Instagram"),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF5E9BC8)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF4A6881),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _linkRow(BuildContext context, IconData icon, String url, String label) {
    if (url.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _copyToClipboard(context, url, label),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F7FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF5E9BC8).withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF5E9BC8)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5E9BC8).withOpacity(0.7),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF2E4A64),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  const Icon(Icons.copy_all_rounded, size: 16, color: Color(0xFF5E9BC8)),
                  Text(
                    "COPY",
                    style: GoogleFonts.poppins(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5E9BC8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}