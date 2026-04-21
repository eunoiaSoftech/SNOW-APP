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

class AppreciationCreateScreen extends StatefulWidget {
  const AppreciationCreateScreen({super.key});

  @override
  State<AppreciationCreateScreen> createState() => _AppreciationCreateScreenState();
}

class _AppreciationCreateScreenState extends State<AppreciationCreateScreen> {
  final repo = AppreciationTestimonialRepository();
  final memberRepo = DirectoryMemberRepository();
  final locationRepo = LocationRepository();
  final commonRepo = CommonRepository();

  final descController = TextEditingController();

  File? imageFile;
  bool isLoading = false;

  LocationData? locationData;
  int? selectedCityId;
  int? selectedIglooId;
  int? selectedMemberId;

  List<IglooOption> igloos = [];
  List members = [];

  final Color primaryColor = const Color(0xFF014576);

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

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  Future<void> submit() async {
    if (selectedMemberId == null) {
      _showSnack("Please select a member");
      return;
    }
    if (imageFile == null) {
      _showSnack("Please upload an image");
      return;
    }
    if (descController.text.trim().isEmpty) {
      _showSnack("Description is required");
      return;
    }

    setState(() => isLoading = true);
    try {
      final imageUrl = await repo.uploadImage(imageFile!);
      final msg = await repo.createAppreciation(
        memberUserId: selectedMemberId!,
        description: descController.text,
        photo: imageUrl,
      );
      _showSnack(msg);
      Navigator.pop(context);
    } catch (e) {
      _showSnack(e.toString());
    }
    setState(() => isLoading = false);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  // Helper UI Methods
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 12),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primaryColor.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildDropdownWrapper(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
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
                        "Create Appreciation",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),

                          _buildLabel("Location"),
                          _buildDropdownWrapper(
                            DropdownButton<int>(
                              isExpanded: true,
                              hint: const Text("Select City"),
                              value: selectedCityId,
                              items: locationData?.countries
                                      .expand((c) => c.zones)
                                      .expand((z) => z.states)
                                      .expand((s) => s.cities)
                                      .map((city) => DropdownMenuItem<int>(
                                            value: city.id,
                                            child: Text(city.name),
                                          ))
                                      .toList() ?? [],
                              onChanged: (val) async {
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
                          ),

                          const SizedBox(height: 12),
                          _buildDropdownWrapper(
                            DropdownButton<int>(
                              isExpanded: true,
                              hint: const Text("Select Igloo"),
                              value: selectedIglooId,
                              items: igloos.map((i) => DropdownMenuItem<int>(value: i.id, child: Text(i.name))).toList(),
                              onChanged: (val) async {
                                setState(() => selectedIglooId = val);
                                await loadMembers();
                              },
                            ),
                          ),

                          _buildLabel("Receiver"),
                          _buildDropdownWrapper(
                            DropdownButton<int>(
                              isExpanded: true,
                              hint: const Text("Select Member"),
                              value: selectedMemberId,
                              items: members.map<DropdownMenuItem<int>>((m) {
                                return DropdownMenuItem<int>(
                                  value: m["user_id"],
                                  child: Text(m["data"]?["full_name"] ?? "User"),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() => selectedMemberId = val),
                            ),
                          ),

                          _buildLabel("Message"),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: descController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: "Why do you appreciate them?",
                                hintStyle: GoogleFonts.poppins(fontSize: 13),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),

                          _buildLabel("Evidence / Photo"),
                          GestureDetector(
                            onTap: pickImage,
                            child: Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5, style: BorderStyle.solid),
                              ),
                              child: imageFile != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.file(imageFile!, fit: BoxFit.cover),
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_a_photo_outlined, color: primaryColor, size: 40),
                                        const SizedBox(height: 8),
                                        Text("Tap to upload photo", style: GoogleFonts.poppins(color: primaryColor, fontSize: 13)),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                elevation: 4,
                              ),
                              child: isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                      "Submit Appreciation",
                                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 30),
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