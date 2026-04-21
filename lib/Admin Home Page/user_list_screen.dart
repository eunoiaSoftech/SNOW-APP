import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/Data/Models/admin_igloo.dart';
import 'package:snow_app/Data/Models/admin_user_entry.dart';
import 'package:snow_app/Data/Repositories/admin_repository.dart';
import 'package:snow_app/core/api_client.dart';
import 'package:snow_app/core/app_toast.dart';
import 'package:snow_app/core/result.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen>
    with SingleTickerProviderStateMixin {
  final AdminRepository _adminRepo = AdminRepository();
  late final TabController _tabs;
  bool _loading = true;

  List<AdminUserEntry> _pendingUsers = [];
  List<AdminUserEntry> _activeUsers = [];
  List<Igloo> _igloos = [];
  final TextEditingController roleCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _init();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    setState(() => _loading = true);
    await Future.wait([_loadUsers(), _loadIgloos()]);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadUsers() async {
    final pendingRes = await _adminRepo.fetchPendingUsers();
    final activeRes = await _adminRepo.fetchUsersByStatus('ACTIVE');
    if (!mounted) return;

    switch (pendingRes) {
      case Ok(value: final list):
        setState(() => _pendingUsers = list);
      case Err(message: final msg, code: _):
        context.showToast('Pending users load failed: $msg', bg: Colors.red);
    }

    switch (activeRes) {
      case Ok(value: final list):
        setState(() => _activeUsers = list);
      case Err(message: final msg, code: _):
        context.showToast('Active users load failed: $msg', bg: Colors.red);
    }
  }

//   Future<void> sendReminder() async {
//   final (res, code) = await ApiClient.create().post(
//     "/",
//     query: {"endpoint": "admin/renewal-reminder"},
//     body: {
//       "user_type_id": userTypeId, // 🔥 THIS IS CRITICAL
//     },
//   );

//   if (code == 200) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(res.data["message"])),
//     );
//   }
// }

  Future<void> _loadIgloos() async {
    final res = await _adminRepo.fetchIgloos();
    if (!mounted) return;
    switch (res) {
      case Ok(value: final list):
        setState(() => _igloos = list);
      case Err(message: final msg, code: _):
        context.showToast('Igloo list load failed: $msg', bg: Colors.red);
    }
  }

  Future<void> _approveUser(
    AdminUserEntry entry,
    DateTime joiningDate,
    int durationYears,
  ) async {
    final res = await _adminRepo.approveUser(
      userTypeId: entry.userTypeId,
      action: 'approve',

      // ✅ NEW FIELDS
      joiningDate: joiningDate,
      durationYears: durationYears,
    );

    if (!mounted) return;

    switch (res) {
      case Ok():
        context.showToast('${entry.displayName} approved');
        await _loadUsers();

      case Err(message: final msg, code: _):
        context.showToast('Approval failed: $msg', bg: Colors.red);
    }
  }

  //   Future<void> _approveUser(
  //   AdminUserEntry entry,
  //   List<int> iglooIds,
  //   String roleName,
  // ) async {
  //   final res = await _adminRepo.approveUser(
  //     userTypeId: entry.userTypeId,
  //     action: 'approve',
  //     iglooIds: iglooIds.isEmpty ? null : iglooIds,
  //     roleName: roleName, // NEW FIELD
  //   );
  //   if (!mounted) return;

  //   switch (res) {
  //     case Ok():
  //       context.showToast('${entry.displayName} approved');
  //       await _loadUsers();

  //     case Err(message: final msg, code: _):
  //       context.showToast('Approval failed: $msg', bg: Colors.red);
  //   }
  // }

  Future<void> _rejectUser(AdminUserEntry entry) async {
    final res = await _adminRepo.approveUser(
      userTypeId: entry.userTypeId,
      action: 'reject',
    );
    if (!mounted) return;
    switch (res) {
      case Ok():
        context.showToast('${entry.displayName} rejected');
        await _loadUsers();
      case Err(message: final msg, code: _):
        context.showToast('Rejection failed: $msg', bg: Colors.red);
    }
  }

  String getIglooNames(AdminUserEntry user) {
    if (user.approvedIgloos.isEmpty) return "No Igloo Assigned";

    return user.approvedIgloos
        .map((e) => e['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .join(', ');
  }

Future<void> _showApproveDialog(AdminUserEntry entry) async {
  DateTime joiningDate = DateTime.now();
  int duration = 1;

  final TextEditingController durationCtrl =
      TextEditingController(text: "1");

  DateTime getExpiry() {
    return DateTime(
      joiningDate.year + duration,
      joiningDate.month,
      joiningDate.day,
    );
  }

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final expiryDate = getExpiry();

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFF8FBFF),
                      const Color(0xFFE8F3FA).withOpacity(0.95),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5E9BC8).withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFF5E9BC8).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
              
                    /// 🔹 TITLE
                    Text(
                      "Approve ${entry.displayName}",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: const Color(0xFF014576),
                      ),
                    ),
              
                    const SizedBox(height: 20),
              
                    /// 📅 JOINING DATE
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Joining Date",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
              
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: joiningDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF5E9BC8), // header
                                  onPrimary: Colors.white,
                                  onSurface: Color(0xFF014576),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
              
                        if (picked != null) {
                          setModalState(() {
                            joiningDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF5E9BC8).withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${joiningDate.day}/${joiningDate.month}/${joiningDate.year}",
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                            const Icon(Icons.calendar_today, size: 18),
                          ],
                        ),
                      ),
                    ),
              
                    const SizedBox(height: 16),
              
                    /// ⏳ DURATION INPUT
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Membership Duration (Years)",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
              
                    TextFormField(
                      controller: durationCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Enter years (e.g. 1, 5, 10)",
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (val) {
                        final parsed = int.tryParse(val);
                        if (parsed != null && parsed > 0) {
                          setModalState(() {
                            duration = parsed;
                          });
                        }
                      },
                    ),
              
                    const SizedBox(height: 12),
              
                    /// 🔹 QUICK CHIPS (UX BOOST)
                    Wrap(
                      spacing: 8,
                      children: [1, 3, 5, 10].map((e) {
                        return ChoiceChip(
                          label: Text("$e Yr"),
                          selected: duration == e,
                          onSelected: (_) {
                            setModalState(() {
                              duration = e;
                              durationCtrl.text = e.toString();
                            });
                          },
                          selectedColor: const Color(0xFF5E9BC8),
                          labelStyle: TextStyle(
                            color:
                                duration == e ? Colors.white : Colors.black87,
                          ),
                        );
                      }).toList(),
                    ),
              
                    const SizedBox(height: 18),
              
                    /// 📅 EXPIRY PREVIEW
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Expiry Date: ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
              
                    const SizedBox(height: 22),
              
                    /// 🔘 BUTTONS
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.poppins(
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
              
                              await _approveUser(
                                entry,
                                joiningDate,
                                duration,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5E9BC8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Approve",style: TextStyle(color: Colors.white),),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF5E9BC8);
    const Color textColor = Color(0xFF2E4A64);

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
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: const Color(0xFF014576),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        "Today's Login",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF014576),
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                // Body
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.45),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            children: [
                              // Tabs
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TabBar(
                                  controller: _tabs,
                                  labelColor: textColor,
                                  unselectedLabelColor: Colors.grey[600],
                                  indicatorColor: Colors.transparent,
                                  dividerColor: Colors.transparent,
                                  indicator: UnderlineTabIndicator(
                                    borderSide: BorderSide(
                                      color: primaryBlue.withOpacity(0.7),
                                      width: 2,
                                    ),
                                    insets: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                    ),
                                  ),
                                  labelStyle: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.5,
                                  ),
                                  tabs: [
                                    Tab(
                                      text: 'Pending (${_pendingUsers.length})',
                                    ),
                                    Tab(
                                      text: 'Active (${_activeUsers.length})',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              Expanded(
                                child: TabBarView(
                                  controller: _tabs,
                                  children: [
                                    _buildPendingTab(),
                                    _buildActiveTab(),
                                  ],
                                ),
                              ),
                            ],
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

  Widget _buildPendingTab() {
    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pendingUsers.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Text(
                      'No users waiting for approval.',
                      style: TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: _pendingUsers.length,
                itemBuilder: (context, index) {
                  final entry = _pendingUsers[index];
                  return _SoftUserCard(
                    entry: entry,
                    onApprove: () => _showApproveDialog(entry),
                    onReject: () => _rejectUser(entry),
                  );
                },
              ),
      ),
    );
  }
// if (isAdmin && userTypeId != null)
//   ElevatedButton(
//     onPressed: sendReminder,
//     child: Text("Send Reminder"),
//   ),
  Widget _buildActiveTab() {
    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _activeUsers.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Text(
                      'No active users to display.',
                      style: TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: _activeUsers.length,
                itemBuilder: (context, index) {
                  final entry = _activeUsers[index];
                  return _SoftUserCard(
                    entry: entry,
                    onApprove: null,
                    onReject: null,
                    isActive: true,
                  );
                },
              ),
      ),
    );
  }
}

class _SoftUserCard extends StatelessWidget {
  final AdminUserEntry entry;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final bool isActive;

  const _SoftUserCard({
    required this.entry,
    this.onApprove,
    this.onReject,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF2E4A64);

    final business = entry.data['business_name']?.toString() ?? '-';
    final category = entry.data['business_category']?.toString();
    final iglooNames = entry.approvedIgloos
        .map((e) => e['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.8),
        border: Border.all(color: Colors.white70, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFF5E9BC8).withOpacity(0.2),
                      child: const Icon(Icons.person, color: Color(0xFF5E9BC8)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.displayName,
                            style: GoogleFonts.poppins(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            entry.email,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            entry.userType.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Business: $business',
                  style: GoogleFonts.poppins(fontSize: 13.5, color: textColor),
                ),
                if (category != null)
                  Text(
                    'Category: $category',
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      color: textColor,
                    ),
                  ),
                const SizedBox(height: 14),

                // const SizedBox(height: 6),
                if (isActive && iglooNames.isNotEmpty)
                  Text(
                    'Igloos: $iglooNames',
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      color: const Color(0xFF2E4A64),
                    ),
                  ),

                if (!isActive)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onApprove,
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Approve'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFB3E5C2)),
                            foregroundColor: const Color(0xFF4A7A58),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onReject,
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFF5B7B1)),
                            foregroundColor: const Color(0xFF804D4D),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
  }
}
