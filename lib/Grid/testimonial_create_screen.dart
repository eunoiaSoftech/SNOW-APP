import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snow_app/Data/Repositories/DirectoryMemberRepository.dart';
import 'package:snow_app/Data/Repositories/New%20Repositories/appreciation_testimonial_repository.dart';
import 'package:snow_app/Data/Repositories/New%20Repositories/location_repo.dart';
import 'package:snow_app/Data/Repositories/common_repository.dart';
import 'package:snow_app/Data/models/New%20Model/location_data123.dart';
import 'package:snow_app/Data/models/New%20Model/newloginmodel/IglooOption.dart';
import 'package:snow_app/core/result.dart';

class TestimonialCreateScreen extends StatefulWidget {
  const TestimonialCreateScreen({super.key});

  @override
  State<TestimonialCreateScreen> createState() => _TestimonialCreateScreenState();
}

class _TestimonialCreateScreenState extends State<TestimonialCreateScreen> {
  final repo = AppreciationTestimonialRepository();
  final memberRepo = DirectoryMemberRepository();
  final locationRepo = LocationRepository();
  final commonRepo = CommonRepository();

  final descController = TextEditingController();
  final linkController = TextEditingController();

  File? imageFile;
  bool isLoading = false;

  LocationData? locationData;
  int? selectedCityId;
  int? selectedIglooId;
  int? selectedMemberId;

  List<IglooOption> igloos = [];
  List members = [];

  // Consistent Colors
  final Color primaryDark = const Color(0xFF014576);
  final Color accentBlue = const Color(0xFF5E9BC8);

  @override
  void initState() {
    super.initState();
    loadLocations();
  }

  Future<void> loadLocations() async {
    final res = await locationRepo.fetchLocationData();
    if (res is Ok<LocationData>) {
      setState(() => locationData = res.value);
    }
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  Future<void> loadMembers() async {
    if (selectedCityId == null) return;
    final data = await memberRepo.fetchMembers(
      cityId: selectedCityId,
      iglooId: selectedIglooId,
    );
    setState(() {
      members = data;
      selectedMemberId = null;
    });
  }

  Future<void> submit() async {
    if (selectedMemberId == null) {
      _showSnackBar("Please select a member");
      return;
    }
    if (imageFile == null) {
      _showSnackBar("Please upload an image");
      return;
    }
    if (descController.text.isEmpty) {
      _showSnackBar("Description is required");
      return;
    }

    setState(() => isLoading = true);
    try {
      final imageUrl = await repo.uploadImage(imageFile!);
      final msg = await repo.createTestimonial(
        memberUserId: selectedMemberId!,
        description: descController.text,
        link: linkController.text,
        photo: imageUrl,
      );
      _showSnackBar(msg);
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar(e.toString());
    }
    setState(() => isLoading = false);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 12),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primaryDark,
        ),
      ),
    );
  }

  Widget _buildDropdownCard(String hint, int? value, List<DropdownMenuItem<int>> items, Function(int?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          hint: Text(hint, style: GoogleFonts.poppins(fontSize: 14)),
          value: value,
          items: items,
          onChanged: onChanged,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryDark),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/bghome.jpg', fit: BoxFit.cover),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF97DCEB).withOpacity(0.7),
                        const Color(0xFF5E9BC8).withOpacity(0.8),
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
                // AppBar area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left_rounded, color: primaryDark, size: 32),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        "New Testimonial",
                        style: GoogleFonts.poppins(
                          color: primaryDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel("Location Details"),
                          _buildDropdownCard(
                            "Select City",
                            selectedCityId,
                            locationData?.countries
                                    .expand((c) => c.zones)
                                    .expand((z) => z.states)
                                    .expand((s) => s.cities)
                                    .map((city) => DropdownMenuItem<int>(
                                          value: city.id,
                                          child: Text(city.name),
                                        ))
                                    .toList() ?? [],
                            (val) async {
                              setState(() {
                                selectedCityId = val;
                                selectedIglooId = null;
                                members = [];
                              });
                              if (val != null) {
                                final res = await commonRepo.fetchIgloosByCity(val);
                                if (res is Ok<List<IglooOption>>) {
                                  setState(() => igloos = res.value);
                                }
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildDropdownCard(
                            "Select Igloo",
                            selectedIglooId,
                            igloos.map((i) => DropdownMenuItem<int>(value: i.id, child: Text(i.name))).toList(),
                            (val) async {
                              setState(() => selectedIglooId = val);
                              await loadMembers();
                            },
                          ),

                          _buildSectionLabel("Member"),
                          _buildDropdownCard(
                            "Select Member",
                            selectedMemberId,
                            members.map<DropdownMenuItem<int>>((m) {
                              return DropdownMenuItem<int>(
                                value: m["user_id"],
                                child: Text(m["data"]?["full_name"] ?? "User"),
                              );
                            }).toList(),
                            (val) => setState(() => selectedMemberId = val),
                          ),

                          _buildSectionLabel("Testimonial Info"),
                          _buildTextField(controller: descController, hint: "Write your description here...", maxLines: 4),
                          const SizedBox(height: 12),
                          _buildTextField(controller: linkController, hint: "Paste video/portfolio link (optional)"),

                          _buildSectionLabel("Attachment"),
                          GestureDetector(
                            onTap: pickImage,
                            child: Container(
                              width: double.infinity,
                              height: 140,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: accentBlue.withOpacity(0.5), width: 2, style: BorderStyle.solid),
                              ),
                              child: imageFile != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(13),
                                      child: Image.file(imageFile!, fit: BoxFit.cover),
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_photo_alternate_outlined, color: accentBlue, size: 40),
                                        const SizedBox(height: 8),
                                        Text("Tap to upload photo", style: GoogleFonts.poppins(color: primaryDark, fontSize: 13)),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryDark,
                                foregroundColor: Colors.white,
                                elevation: 5,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                      "Submit Testimonial",
                                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
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