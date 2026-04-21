import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/Data/Repositories/New%20Repositories/appreciation_testimonial_repository.dart';
import 'testimonial_create_screen.dart';

class TestimonialListScreen extends StatefulWidget {
  const TestimonialListScreen({super.key});

  @override
  State<TestimonialListScreen> createState() => _TestimonialListScreenState();
}

class _TestimonialListScreenState extends State<TestimonialListScreen> {
  final repo = AppreciationTestimonialRepository();
  final Color primaryColor = const Color(0xFF014576);

  List data = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => loading = true);
    try {
      final res = await repo.getTestimonials();
      setState(() {
        data = res;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  /// Extracts the active member's name from the nested user_types list
  String getMemberName(dynamic item) {
    try {
      // Find the user_type that matches the active_user_type_id
      final activeId = item["member"]?["active_user_type_id"];
      final userTypes = item["member"]?["user_types"] as List?;
      
      if (userTypes != null) {
        final activeType = userTypes.firstWhere(
          (element) => element["id"] == activeId,
          orElse: () => userTypes.first,
        );
        return activeType["data"]?["full_name"] ?? "Unknown Member";
      }
    } catch (e) {
      return "Member";
    }
    return "Unknown Member";
  }

  /// Extracts who created the testimonial
  String getCreatorName(dynamic item) {
    return item["creator"]?["display_name"] ?? "System";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🌄 BACKGROUND
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/bghome.jpg', fit: BoxFit.cover),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xCC97DCEB), Color(0xCC5E9BC8)],
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// CONTENT
          SafeArea(
            child: Column(
              children: [
                /// HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new, color: primaryColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        "Testimonials",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.refresh_rounded, color: primaryColor),
                        onPressed: loadData,
                      )
                    ],
                  ),
                ),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.35),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: loading
                        ? Center(child: CircularProgressIndicator(color: primaryColor))
                        : data.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  return _buildTestimonialCard(data[index]);
                                },
                              ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      /// ✅ FLOATING ACTION BUTTON
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TestimonialCreateScreen()),
          );
          loadData();
        },
        icon: const Icon(Icons.rate_review_rounded, color: Colors.white),
        label: Text("Write One", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTestimonialCard(dynamic item) {
    final photoUrl = item["photo"] ?? "";
    final link = item["link"] ?? "";
    final description = item["description"] ?? "";
    final creator = getCreatorName(item);
    final memberName = getMemberName(item);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // USER INFO HEADER
          ListTile(
            leading: CircleAvatar(
              backgroundColor: primaryColor.withOpacity(0.1),
              child: Icon(Icons.person_outline, color: primaryColor),
            ),
            title: Text(
              memberName,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 15),
            ),
            subtitle: Text(
              "Created by: $creator",
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
            ),
            trailing: Icon(Icons.format_quote_rounded, color: primaryColor.withOpacity(0.2), size: 30),
          ),

          // TESTIMONIAL TEXT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              description,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87, height: 1.5),
            ),
          ),

          // WEBSITE/LINK BUTTON
          if (link.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.link, size: 16, color: Colors.blue),
                    const SizedBox(width: 6),
                    Text(
                      "Visit Link",
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),

          // PHOTO SECTION
          if (photoUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  photoUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(height: 200, color: Colors.grey.shade100, child: const Center(child: CircularProgressIndicator()));
                  },
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ),
          
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.speaker_notes_off_outlined, size: 80, color: primaryColor.withOpacity(0.2)),
        const SizedBox(height: 16),
        Text("No Testimonials", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor.withOpacity(0.5))),
      ],
    );
  }
}