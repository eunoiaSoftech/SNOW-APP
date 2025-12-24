import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/Data/Models/admin_igloo.dart';
import 'package:snow_app/Data/Models/admin_user_entry.dart';
import 'package:snow_app/Data/Repositories/admin_repository.dart';
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

  Future<void> _approveUser(AdminUserEntry entry, List<int> iglooIds) async {
    final res = await _adminRepo.approveUser(
      userTypeId: entry.userTypeId,
      action: 'approve',
      iglooIds: iglooIds.isEmpty ? null : iglooIds,
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

  Future<void> _showApproveDialog(AdminUserEntry entry) async {
    final selected = <int>{};
    final String aadharUrl = entry.aadharFile ?? '';
    debugPrint('Aadhaar URL => $aadharUrl');

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 40,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFF8FBFF),
                  const Color(0xFFE8F3FA).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5E9BC8).withOpacity(0.15),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: const Color(0xFF5E9BC8).withOpacity(0.3),
                width: 1.2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (aadharUrl.isNotEmpty) ...[
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Icon(
                          Icons.credit_card,
                          size: 18,
                          color: Color(0xFF014576),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Aadhaar Card',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: const Color(0xFF014576),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            backgroundColor: Colors.black,
                            insetPadding: const EdgeInsets.all(20),
                            child: Stack(
                              children: [
                                InteractiveViewer(
                                  child: Image.network(
                                    aadharUrl,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF5E9BC8).withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.visibility,
                              size: 18,
                              color: Color(0xFF5E9BC8),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'View Aadhaar',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF014576),
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.open_in_new,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],

                  // 🩵 Title
                  Text(
                    'Assign Igloos to ${entry.displayName}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: const Color(0xFF014576),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🌫️ Igloo list area
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF5E9BC8).withOpacity(0.15),
                      ),
                    ),
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: _igloos.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'No igloos available. Approve without assignment?',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : StatefulBuilder(
                            builder: (context, setModalState) {
                              return ListView.separated(
                                shrinkWrap: true,
                                itemCount: _igloos.length,
                                separatorBuilder: (_, __) => Divider(
                                  color: const Color(
                                    0xFF5E9BC8,
                                  ).withOpacity(0.1),
                                  height: 1,
                                ),
                                itemBuilder: (context, index) {
                                  final igloo = _igloos[index];
                                  return CheckboxListTile(
                                    activeColor: const Color(0xFF5E9BC8),
                                    checkColor: Colors.white,
                                    dense: true,
                                    value: selected.contains(igloo.id),
                                    title: Text(
                                      igloo.name,
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF014576),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14.5,
                                      ),
                                    ),
                                    subtitle: Text(
                                      igloo.cityName ?? '',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.5,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    onChanged: (checked) {
                                      setModalState(() {
                                        if (checked == true) {
                                          selected.add(igloo.id);
                                        } else {
                                          selected.remove(igloo.id);
                                        }
                                      });
                                    },
                                  );
                                },
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 22),

                  // ✨ Buttons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF014576),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: const Color(0xFF014576),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _approveUser(entry, selected.toList());
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 3,
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF014576),
                          shadowColor: const Color(0xFF5E9BC8).withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(
                              color: Color(0xFF5E9BC8),
                              width: 1.2,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                        ),
                        child: Text(
                          'Confirm',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
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
