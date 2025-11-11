import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snow_app/Data/Models/profile_overview.dart';
import 'package:snow_app/core/app_toast.dart';
import 'package:snow_app/core/module_access_service.dart';
import 'package:snow_app/core/result.dart';
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

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    final res = await _repo.fetchProfile();
    if (!mounted) return;
    switch (res) {
      case Ok(value: final profile):
        _moduleService.updateModules(profile.modules);
      setState(() {
          _profile = profile;
          _loading = false;
        });
      case Err(message: final msg, code: final code):
        setState(() => _loading = false);
        final suffix = code > 0 ? ' ($code)' : '';
        context.showToast('Failed to load profile$suffix: $msg', bg: Colors.red);
    }
  }

  Future<void> _switchUserType(int userTypeId) async {
    if (_switching) return;
    setState(() => _switching = true);
    final res = await _repo.switchUserType(userTypeId);
    if (!mounted) return;
    switch (res) {
      case Ok():
        context.showToast('Switched user type successfully');
        setState(() => _switching = false);
        await _loadProfile();
      case Err(message: final msg, code: final code):
        setState(() => _switching = false);
        final suffix = code > 0 ? ' ($code)' : '';
        context.showToast('Switch failed$suffix: $msg', bg: Colors.red);
    }
  }

 Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('isAdmin');
    await prefs.remove('userRole');

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'My Profile',
              style: GoogleFonts.poppins(
                color: const Color(0xFF014576),
                fontWeight: FontWeight.w600,
              ),
            ),
                  actions: [
              TextButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
                style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF5E9BC8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                          Center(child: Text('No profile data available.')),
                        ],
                      )
                    : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
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
                          ],
                        ),
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(ProfileUser user) {
    return Container(
      width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFFEAF5FC), Color(0xFFD8E7FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(2, 4)),
                ],
              ),
              padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
          Row(
                                children: [
                                  CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFF5E9BC8),
                child: Text(
                  user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 26, color: Colors.white),
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
                            const SizedBox(height: 16),
                            Row(
                              children: [
              _buildChip('Active Type', user.activeUserType ?? 'N/A'),
              const SizedBox(width: 8),
              if (user.isAdmin) _buildChip('Admin', 'Yes'),
            ],
                                ),
                              ],
                            ),
    );
  }

  Widget _buildUserTypeSwitcher(ProfileOverview profile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFF9FBFF), Color(0xFFE4F1FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(2, 3)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Switch User Type',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF014576),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
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
          if (_switching) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildModulesCard(List<ModuleAccess> modules) {
    return Container(
      width: double.infinity,
                                  decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFF2F8FF), Color(0xFFE3F0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(2, 3)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Modules',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
              color: const Color(0xFF014576),
            ),
          ),
          const SizedBox(height: 12),
          if (modules.isEmpty)
            const Text('No modules assigned.')
          else
            Column(
              children: modules.map((module) {
                final enabled = module.isEnabled;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    enabled ? Icons.check_circle : Icons.cancel,
                    color: enabled ? Colors.green : Colors.red,
                  ),
                  title: Text(module.name),
                  subtitle: Text(module.description.isEmpty ? module.slug : module.description),
                  trailing: Text(enabled ? 'Enabled' : 'Disabled'),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildIgloosCard(List<IglooMembership> igloos) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFFDF4FF), Color(0xFFEFE0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(2, 3)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Igloos',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF014576),
            ),
          ),
          const SizedBox(height: 12),
          if (igloos.isEmpty)
            const Text('No igloo assignments yet.')
          else
            Column(
              children: igloos.map((igloo) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.ac_unit, color: Color(0xFF5E9BC8)),
                  title: Text(igloo.name),
                  subtitle: Text('${igloo.mode.toUpperCase()} • ${igloo.meetingTime}'),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String value) {
    return Chip(
      label: Text('$label: $value'),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }
}
