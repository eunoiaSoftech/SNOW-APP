import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for Clipboard
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/Data/Repositories/DirectoryMemberRepository.dart';
import 'package:snow_app/Data/Repositories/New%20Repositories/location_repo.dart';
import 'package:snow_app/Data/Repositories/common_repository.dart';
import 'package:snow_app/Data/models/New%20Model/location_data123.dart';
import 'package:snow_app/Data/models/New%20Model/newloginmodel/IglooOption.dart';
import 'package:snow_app/core/result.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final DirectoryMemberRepository repo = DirectoryMemberRepository();
  final LocationRepository locationRepo = LocationRepository();
  final CommonRepository commonRepo = CommonRepository();

  int? selectedCityId;
  int? selectedIglooId;

  bool loading = true;
  List members = [];
  LocationData? locationData;
  List<IglooOption> igloos = []; // ✅ NOT dynamic

  @override
  void initState() {
    super.initState();
    loadFilters();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Material(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 26,
                      ),
                      decoration: BoxDecoration(
                        // ✅ MATCH YOUR SCREEN GRADIENT
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xCC97DCEB),
                            Color(0xCC5E9BC8),
                            Color(0xCC97DCEB),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 🔹 HEADER
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Filter Members",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF014576),
                                ),
                              ),

                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Color(0xFF014576),
                                ),
                                onPressed: () {
                                  if (selectedCityId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "⚠ Please select a city first",
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).pop();
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          /// 🔹 CITY DROPDOWN
                          Text(
                            "Select City *",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                isExpanded: true,
                                hint: const Text("Choose city"),
                                value: selectedCityId,
                                items:
                                    locationData?.countries
                                        .expand((c) => c.zones)
                                        .expand((z) => z.states)
                                        .expand((s) => s.cities)
                                        .map(
                                          (city) => DropdownMenuItem<int>(
                                            value: city.id,
                                            child: Text(city.name),
                                          ),
                                        )
                                        .toList() ??
                                    [],
                                onChanged: (val) async {
                                  if (val == null) return;

                                  setDialogState(() {
                                    selectedCityId = val;
                                    selectedIglooId = null;
                                    igloos = [];
                                  });

                                  final res = await commonRepo
                                      .fetchIgloosByCity(val);

                                  if (res is Ok<List<IglooOption>>) {
                                    setDialogState(() {
                                      igloos = res.value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          /// 🔹 IGLOO DROPDOWN
                          Text(
                            "Select Igloo (Optional)",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                isExpanded: true,
                                value: selectedIglooId,
                                hint: const Text("Choose igloo"),
                                items: igloos
                                    .map<DropdownMenuItem<int>>(
                                      (igloo) => DropdownMenuItem<int>(
                                        value: igloo.id,
                                        child: Text(igloo.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  setDialogState(() {
                                    selectedIglooId = val;
                                  });
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),

                          /// 🔹 APPLY BUTTON (STRICT VALIDATION)
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF014576),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () async {
                                if (selectedCityId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "⚠ Please select a city first",
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                // ✅ CLOSE POPUP PROPERLY
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();

                                // ✅ THEN LOAD DATA
                                setState(() => loading = true);

                                final data = await repo.fetchMembers(
                                  cityId: selectedCityId,
                                  iglooId: selectedIglooId,
                                );

                                setState(() {
                                  members = data;
                                  loading = false;
                                });
                              },
                              child: const Text(
                                "Apply Filters",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  } // --- HELPER STYLING METHODS ---

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDropdownContainer({required Widget child, bool enabled = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: enabled ? Colors.black12 : Colors.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          if (enabled)
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: child,
    );
  }

  Future<void> loadFilters() async {
    final locationResult = await locationRepo.fetchLocationData();

    if (locationResult is Ok<LocationData>) {
      setState(() {
        locationData = locationResult.value; // ✅ FIXED
        loading = false;
      });

      // ✅ SHOW POPUP ONLY AFTER DATA READY
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showFilterDialog();
      });
    }
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
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 16),
                //   child:

                //   Column(
                //     children: [
                //       DropdownButtonFormField<int>(
                //         hint: const Text("Select City"),
                //         value: selectedCityId,
                //         items:
                //             locationData?.countries
                //                 .expand((c) => c.zones)
                //                 .expand((z) => z.states)
                //                 .expand((s) => s.cities)
                //                 .map(
                //                   (city) => DropdownMenuItem(
                //                     value: city.id,
                //                     child: Text(city.name),
                //                   ),
                //                 )
                //                 .toList() ??
                //             [],
                //         onChanged: (val) async {
                //           setState(() {
                //             selectedCityId = val;
                //             selectedIglooId =
                //                 null; // reset igloo when city changes
                //           });

                //           if (val == null) return;

                //           final res = await commonRepo.fetchIgloosByCity(val);

                //           if (res is Ok<List<IglooOption>>) {
                //             setState(() {
                //               igloos = res.value;
                //             });
                //           } else {
                //             setState(() {
                //               igloos = [];
                //             });
                //           }
                //         },
                //       ),

                //       const SizedBox(height: 10),

                //       DropdownButtonFormField<int>(
                //         hint: const Text("Select Igloo (Optional)"),
                //         value: selectedIglooId,
                //         items: igloos
                //             .map<DropdownMenuItem<int>>(
                //               (igloo) => DropdownMenuItem<int>(
                //                 value: igloo.id,
                //                 child: Text(igloo.name),
                //               ),
                //             )
                //             .toList(),
                //         onChanged: (int? val) {
                //           setState(() {
                //             selectedIglooId = val;
                //           });
                //         },
                //       ),
                //       const SizedBox(height: 10),

                //       ElevatedButton(
                //         onPressed: () async {
                //           if (selectedCityId == null) {
                //             ScaffoldMessenger.of(context).showSnackBar(
                //               const SnackBar(
                //                 content: Text("Please select city"),
                //               ),
                //             );
                //             return;
                //           }

                //           setState(() => loading = true);

                //           final data = await repo.fetchMembers(
                //             cityId: selectedCityId,
                //             iglooId: selectedIglooId,
                //           );

                //           setState(() {
                //             members = data;
                //             loading = false;
                //           });
                //         },
                //         // onPressed: () async {
                //         //   setState(() => loading = true);

                //         //   final data = await repo.fetchMembers(
                //         //     cityId: selectedCityId,
                //         //     iglooId: selectedIglooId,
                //         //   );

                //         //   setState(() {
                //         //     members = data;
                //         //     loading = false;
                //         //   });
                //         // },
                //         child: const Text("Apply Filter"),
                //       ),

                //     ],
                //   ),

                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF014576),
                        ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF014576).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF014576).withOpacity(0.2),
                            ),
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

                      Spacer(),

                      IconButton(
                        icon: const Icon(
                          Icons.filter_alt_rounded,
                          color: Color(0xFF014576),
                        ),
                        onPressed: _showFilterDialog,
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
                            // onRefresh: loadMembers,
                            onRefresh: () async {
                              if (selectedCityId != null) {
                                final data = await repo.fetchMembers(
                                  cityId: selectedCityId,
                                  iglooId: selectedIglooId,
                                );

                                setState(() {
                                  members = data;
                                });
                              }
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              physics: const BouncingScrollPhysics(),
                              itemCount: members.length,
                              itemBuilder: (context, index) {
                                final igloos =
                                    (members[index]["approved_igloos"] as List?)
                                        ?.map(
                                          (e) => Map<String, dynamic>.from(e),
                                        )
                                        .toList() ??
                                    [];
                                final m = members[index];
                                final data = m["data"] ?? {};
                                final user = m["user"] ?? {};

                                final country = getCountry(data["country"]);
                                final zone = getZone(data["zone"]);
                                final state = getState(data["state"]);
                                final city = getCity(data["city"]);

                                List<String> locParts = [
                                  city,
                                  state,
                                  zone,
                                  country,
                                ].where((s) => s.isNotEmpty).toList();
                                final locationString = locParts.join(", ");

                                return _MemberCard(
                                  name:
                                      data["full_name"] ??
                                      user["display_name"] ??
                                      "",
                                  email: data["email"] ?? user["email"] ?? "",
                                  contact: data["contact"] ?? "",
                                  business: data["business_name"] ?? "",
                                  category: data["business_category"] ?? "",
                                  description:
                                      data["company_description"] ?? "",
                                  linkedin: data["linkedin_id"] ?? "",
                                  facebook: data["facebook_id"] ?? "",
                                  instagram: data["instagram_id"] ?? "",
                                  location: locationString,
                                  igloos: igloos,
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
  final String name,
      email,
      contact,
      business,
      category,
      description,
      linkedin,
      facebook,
      instagram,
      location;
  final List<Map<String, dynamic>> igloos;

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
    this.igloos = const [],
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
          ),
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

                if (igloos.isNotEmpty) ...[
                  const SizedBox(height: 20),

                  /// 🏷️ Minimalist Section Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Row(
                      children: [
                        // A subtle vertical accent line instead of a bulky icon
                        Container(
                          width: 3,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF5E9BC8),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Active Igloos",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(
                              0xFF263238,
                            ), // Darker for better readability
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// 🧊 Soft Floating Chips
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: igloos.map<Widget>((igloo) {
                      final name = igloo["name"] ?? "";

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          // Subtle border to give it structure without being "loud"
                          border: Border.all(
                            color: const Color(0xFFE1E8ED),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5E9BC8).withOpacity(0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Text(
                          name,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF014576),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                if (location.isNotEmpty)
                  _infoRow(Icons.location_on_outlined, location),
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
                if (linkedin.isNotEmpty ||
                    facebook.isNotEmpty ||
                    instagram.isNotEmpty) ...[
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
                  if (linkedin.isNotEmpty)
                    _linkRow(context, Icons.link, linkedin, "LinkedIn"),
                  if (facebook.isNotEmpty)
                    _linkRow(context, Icons.facebook, facebook, "Facebook"),
                  if (instagram.isNotEmpty)
                    _linkRow(
                      context,
                      Icons.camera_alt_outlined,
                      instagram,
                      "Instagram",
                    ),
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

  Widget _linkRow(
    BuildContext context,
    IconData icon,
    String url,
    String label,
  ) {
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
                  const Icon(
                    Icons.copy_all_rounded,
                    size: 16,
                    color: Color(0xFF5E9BC8),
                  ),
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
