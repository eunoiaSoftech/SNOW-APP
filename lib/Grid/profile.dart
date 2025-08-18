import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/Data/models/user.dart';
import 'package:snow_app/core/app_toast.dart';
import 'package:snow_app/data/repositories/profile_repository.dart';
import '../core/result.dart';
import '../../Data/Models/profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _repo = ProfileRepository();
  ProfileModel? _data;
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  // Controllers for editable fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _businessController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final res = await _repo.getProfile();
    if (res is Ok<ProfileModel>) {
      _data = res.value;
      _nameController.text = _data!.profile!.fullName;
      _emailController.text = _data!.profile!.email;
      _businessController.text = _data!.profile!.businessName ?? '';
      _cityController.text = _data!.profile!.city ?? '';
      setState(() {});
    } else if (res is Err) {
      context.showToast('Could not fetch profile', bg: Colors.red);
    }
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF014576),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel(label),
        TextFormField(
          controller: controller,
          validator: (val) {
            if (val == null || val.isEmpty) return '$label cannot be empty';
            return null;
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

 Future<void> _saveProfile() async {
  if (!_formKey.currentState!.validate()) {
    context.showToast('Please fix the errors');
    return;
  }

  setState(() => _loading = true);

  final body = {
    "full_name": _nameController.text.trim(),
    "email": _emailController.text.trim(),
    "business_name": _businessController.text.trim(),
    "city": _cityController.text.trim(),
  };

  final res = await _repo.updateProfile(body);

  if (res is Ok) {
    // Successfully updated, now fetch latest profile
    final profileRes = await _repo.getProfile();
    setState(() => _loading = false);

    if (profileRes is Ok<ProfileModel>) {
      _data = profileRes.value;
      _nameController.text = _data!.profile!.fullName;
      _emailController.text = _data!.profile!.email;
      _businessController.text = _data!.profile!.businessName ?? '';
      _cityController.text = _data!.profile!.city ?? '';
      context.showToast('Profile updated successfully');
    } else if (profileRes is Err) {
      context.showToast('Updated but failed to fetch latest data', bg: Colors.orange);
    }
  } else if (res is Err) {
    setState(() => _loading = false);
    context.showToast('Failed to update profile', bg: Colors.red);
  }
}


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image + gradient
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

        // Foreground content
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              "My Profile",
              style: GoogleFonts.poppins(
                color: const Color(0xFF014576),
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
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFFEAF5FC), Color(0xFFD8E7FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: _data == null
                  ? const Center(child: CircularProgressIndicator())
                  : Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildTextField('Name', _nameController),
                            buildTextField('Email', _emailController),
                            buildTextField('Business', _businessController),
                            buildTextField('City', _cityController),
                            if (_data?.registeredDate != null) ...[
                              buildLabel('Registered On'),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                child: Text(
                                  _data!.registeredDate!,
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: Colors.white,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: _loading ? null : _saveProfile,
                                child: Ink(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF5E9BC8),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: _loading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : Text(
                                            'Save',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
