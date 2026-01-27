import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snow_app/Data/Models/profile_overview.dart';
import 'package:snow_app/core/app_error_handler.dart';
import 'package:snow_app/core/app_toast.dart';
import 'package:snow_app/core/module_access_service.dart';
import 'package:snow_app/core/result.dart';
import 'package:snow_app/core/snow_snackbar.dart';
import 'package:snow_app/data/repositories/profile_repository.dart';
import 'package:snow_app/logins/login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileRepository _repo = ProfileRepository();
  final ModuleAccessService _moduleService = ModuleAccessService();

  ProfileOverview? _profile;
  bool _loading = false;
  bool _switching = false;
  double _opacity = 1.0;
  double _marginTop = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _showDeleteAccountPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Account Deletion",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF014576),
            ),
          ),
          content: Text(
            "If you wish to delete your account, please contact our support team at:\n\n"
            "delete@app.snowbiizglobal.com\n\n"
            "Our team will guide you through the process.",
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.5,
              color: Colors.blueGrey[700],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Okay",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF014576),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDeleteAccountButton() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Account Settings",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF014576),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: const Color(0xFF5E9BC8).withOpacity(0.6),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _showDeleteAccountPopup,
              child: Text(
                "Delete Account",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF014576),
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);

    final res = await _repo.fetchProfile();
    if (!mounted) return;

    setState(() => _loading = false);

    switch (res) {
      case Ok(value: final profile):
        _moduleService.updateModules(profile.modules);
        setState(() {
          _profile = profile;
        });
        break;

      case Err(message: final msg, code: final code):
        AppErrorHandler.show(context, error: msg, code: code, message: msg);
        break;
    }
  }

  Future<void> _switchUserType(int userTypeId) async {
    if (_switching) return;
    setState(() => _switching = true);

    final res = await _repo.switchUserType(userTypeId);
    if (!mounted) return;

    setState(() => _switching = false);

    switch (res) {
      case Ok():
        SnowSnackBar.show(
          context,
          message: "Switched user type successfully",
          bgColor: Colors.green,
          icon: Icons.check_circle,
        );
        await _loadProfile();
        break;

      case Err(message: final msg, code: final code):
        AppErrorHandler.show(context, error: msg, code: code, message: msg);
        break;
    }
  }

  Future<void> _logout() async {
    _confirmLogout();
  }

  void _confirmLogout() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Logout",
      transitionDuration: Duration(milliseconds: 400),

      pageBuilder: (context, animation, secondaryAnimation) {
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

                  // cute baby-blue shadow
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF5E9BC8).withOpacity(0.25),
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    ),
                  ],

                  // thin border
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
                        color: Colors.blueGrey[600],
                        fontSize: 15,
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Cancel Button
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

                        // Logout Button — with ORIGINAL LOGIC ❤️
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

                          onPressed: () async {
                            Navigator.pop(context);

                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.clear();

                            SnowSnackBar.show(
                              context,
                              message: "Logged out successfully!",
                              bgColor: Colors.green,
                              icon: Icons.check_circle,
                            );

                            if (!mounted) return;

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                              (route) => false,
                            );
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Stack(
        children: [
          // 🌟 FIXED FULLSCREEN BACKGROUND (no bottom gap ever)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/bghome.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF97DCEB).withOpacity(0.55),
                      const Color(0xFF5E9BC8).withOpacity(0.55),
                      const Color(0xFF70A9EE).withOpacity(0.55),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          // 🌟 SCAFFOLD NOW FILLS SCREEN PROPERLY
          Scaffold(
            extendBody: true,
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.transparent,

            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                "My Profile",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF014576),
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                TextButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                  label: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF5E9BC8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),

            body: RefreshIndicator(
              onRefresh: _loadProfile,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _profile == null
                  ? ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(child: Text("No profile data available.")),
                      ],
                    )
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        kToolbarHeight + 16,
                        16,
                        16,
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildUserCard(_profile!.user),
                          const SizedBox(height: 16),
                          _buildUserTypeSwitcher(_profile!),
                          const SizedBox(height: 16),
                          _buildModulesCard(_profile!.modules),
                          const SizedBox(height: 16),
                          _buildIgloosCard(_profile!.igloos),
                          const SizedBox(height: 20),
                          _buildDeleteAccountButton(),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // 🌟 GLASSMORPHIC CARD
  Widget _glassCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.85),
            Colors.white.withOpacity(0.65),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5E9BC8).withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(padding: const EdgeInsets.all(20), child: child),
        ),
      ),
    );
  }

  // -------------------------------
  // USER CARD
  // -------------------------------
  Widget _buildUserCard(ProfileUser user) {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: const Color(0xFF5E9BC8).withOpacity(0.15),
                child: Text(
                  user.fullName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 28,
                    color: Color(0xFF014576),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF014576),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(user.email, style: GoogleFonts.poppins(fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              _buildChip("Active Type", user.activeUserType ?? "N/A"),
              const SizedBox(width: 8),
              if (user.isAdmin) _buildChip("Admin", "Yes"),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------
  // USER TYPE SWITCHER
  // -------------------------------
  Widget _buildUserTypeSwitcher(ProfileOverview profile) {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Switch User Type"),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: profile.userTypes.map((type) {
                final isActive = type.id == profile.user.activeUserTypeId;

                return ChoiceChip(
                  label: Text(type.userType.toUpperCase()),
                  selected: isActive,
                  selectedColor: const Color(0xFF5E9BC8),
                  labelStyle: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFF014576),
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (selected) {
                    if (!selected || isActive) return;
                    _switchUserType(type.id);
                  },
                );
              }).toList(),
            ),
          ),

          if (_switching) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }

  // -------------------------------
  // MODULES CARD
  // -------------------------------
  Widget _buildModulesCard(List<ModuleAccess> modules) {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Modules"),
          const SizedBox(height: 12),

          if (modules.isEmpty)
            SizedBox(
              width: double.infinity,
              child: const Text("No modules assigned."),
            )
          else
            Column(
              children: modules.map((module) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    module.isEnabled ? Icons.check_circle : Icons.cancel,
                    color: module.isEnabled ? Colors.green : Colors.red,
                  ),
                  title: Text(module.name),
                  subtitle: Text(
                    module.description.isEmpty
                        ? module.slug
                        : module.description,
                  ),
                  trailing: Text(module.isEnabled ? "Enabled" : "Disabled"),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // -------------------------------
  // IGLOOS CARD
  // -------------------------------
  Widget _buildIgloosCard(List<IglooMembership> igloos) {
    return _glassCard(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title("Igloos"),
            const SizedBox(height: 12),
            if (igloos.isEmpty)
              const Text("No igloo assignments yet.")
            else
              Column(
                children: igloos.map((igloo) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.ac_unit,
                      color: Color(0xFF5E9BC8),
                    ),
                    title: Text(igloo.name),
                    subtitle: Text(
                      "${igloo.mode.toUpperCase()} • ${igloo.meetingTime}",
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  // -------------------------------
  // COMMON WIDGETS
  // -------------------------------
  Widget _title(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF014576),
      ),
    );
  }

  Widget _buildChip(String label, String value) {
    return Chip(
      backgroundColor: Colors.white,
      label: Text("$label: $value"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
