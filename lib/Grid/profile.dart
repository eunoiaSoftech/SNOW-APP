import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snow_app/Data/models/user.dart';
import 'package:snow_app/core/app_toast.dart';
import 'package:snow_app/data/repositories/profile_repository.dart';
import 'package:snow_app/logins/login.dart';
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
  double _opacity = 1.0;
  double _marginTop = 0;

  void _animateSnowflake() {
    Future.delayed(Duration.zero, () async {
      while (mounted) {
        setState(() {
          _opacity = 1.0;
          _marginTop = 0;
        });
        await Future.delayed(Duration(seconds: 3));
        setState(() {
          _opacity = 0.0;
          _marginTop = 20; // slide down
        });
        await Future.delayed(Duration(seconds: 2));
      }
    });
  }

  // Controllers for editable fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _businessController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _animateSnowflake);

    _loadProfile();
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  void _confirmLogout() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Logout",
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        // This won't be used; see transitionBuilder instead
        return SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedValue = Curves.easeInOut.transform(animation.value);

        return Transform.scale(
          scale: 0.95 + curvedValue * 0.05,
          child: Opacity(
            opacity: animation.value,
            child: Center(
              child: Container(
                padding: EdgeInsets.all(24),
                margin: EdgeInsets.symmetric(horizontal: 28),

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      Color(0xFFE3F3FE),
                      Color(0xFFBDE2FC),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: const Color.fromARGB(255, 179, 220, 255),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: Duration(seconds: 5),
                      curve: Curves.easeOutExpo,
                      margin: EdgeInsets.only(top: _marginTop, bottom: 8),
                      child: AnimatedOpacity(
                        duration: Duration(seconds: 5),
                        opacity: _opacity,
                        child: Text(
                          "❄️",
                          style: TextStyle(
                            fontSize: 48,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Logout from SnowApp?",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Color(0xFF014576),
                        letterSpacing: 0.4,
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Are you sure you want to log out?\nWe'll miss you in the snow! ☃️",
                      style: GoogleFonts.poppins(
                        decoration: TextDecoration.none,

                        color: Colors.blueGrey[600],
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blueGrey[600],
                            backgroundColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          icon: Text("🙅‍♂️", style: TextStyle(fontSize: 20)),
                          label: Text(
                            "Cancel",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF014576),
                            padding: EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            shadowColor: Colors.blue[100],
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _logout();
                          },
                          icon: Text("🚪", style: TextStyle(fontSize: 22)),
                          label: Text(
                            "Logout",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
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
        context.showToast(
          'Updated but failed to fetch latest data',
          bg: Colors.orange,
        );
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
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ElevatedButton.icon(
                  onPressed: _confirmLogout,
                  icon: const Icon(Icons.logout, size: 20, color: Colors.white),
                  label: Text(
                    "Logout",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    backgroundColor: const Color(0xFF5E9BC8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.2),
                  ),
                ),
              ),
            ],
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
                            // if (_data?.registeredDate != null) ...[
                            //   buildLabel('Registered On'),
                            //   Container(
                            //     padding: const EdgeInsets.all(12),
                            //     decoration: BoxDecoration(
                            //       color: Colors.white,
                            //       borderRadius: BorderRadius.circular(12),
                            //       border: Border.all(
                            //         color: Colors.grey.shade400,
                            //       ),
                            //     ),
                            //     child: Text(
                            //       _data!.registeredDate!,
                            //       style: GoogleFonts.poppins(fontSize: 16),
                            //     ),
                            //   ),
                            //   const SizedBox(height: 16),
                            // ],
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
