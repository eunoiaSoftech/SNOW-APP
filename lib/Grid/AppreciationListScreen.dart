import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/Data/Repositories/New%20Repositories/appreciation_testimonial_repository.dart';
import 'appreciation_create_screen.dart';

class AppreciationListScreen extends StatefulWidget {
  const AppreciationListScreen({super.key});

  @override
  State<AppreciationListScreen> createState() => _AppreciationListScreenState();
}

class _AppreciationListScreenState extends State<AppreciationListScreen> {
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
      final res = await repo.getAppreciations();
      setState(() {
        data = res;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  String getMemberName(item) {
    return item["member"]?["user_types"]?[0]?["data"]?["full_name"] ?? "Unknown Member";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🌄 BACKGROUND (Matches Create Screen)
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
                        "Appreciations",
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
                      color: Colors.white.withOpacity(0.3),
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
                                  return _buildAppreciationCard(data[index]);
                                },
                              ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      /// ✅ STYLISH FAB
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AppreciationCreateScreen()),
          );
          loadData();
        },
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          "Create New",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAppreciationCard(dynamic item) {
    final photoUrl = item["photo"] ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section of card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: primaryColor.withOpacity(0.1),
                  child: Icon(Icons.person, color: primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getMemberName(item),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        "Appreciation received",
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.stars_rounded, color: Colors.amber.shade700, size: 28),
              ],
            ),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              item["description"] ?? "",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Image Section
          if (photoUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  photoUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 100,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.auto_awesome_motion_rounded, size: 80, color: primaryColor.withOpacity(0.2)),
        const SizedBox(height: 16),
        Text(
          "No appreciations yet",
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: primaryColor.withOpacity(0.5)),
        ),
        const SizedBox(height: 8),
        Text(
          "Tap the button below to recognize someone!",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}