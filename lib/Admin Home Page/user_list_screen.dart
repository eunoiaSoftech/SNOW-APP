
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
    await Future.wait([
      _loadUsers(),
      _loadIgloos(),
    ]);
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
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Assign Igloos to ${entry.displayName}'),
          content: SizedBox(
            width: double.maxFinite,
            child: _igloos.isEmpty
                ? const Text('No igloos available. Approve without assignment?')
                : StatefulBuilder(
                    builder: (context, setModalState) {
                      return ListView(
                        shrinkWrap: true,
                        children: _igloos
                            .map(
                              (igloo) => CheckboxListTile(
                                value: selected.contains(igloo.id),
                                title: Text(igloo.name),
                                subtitle: Text(igloo.cityName ?? ''),
                                onChanged: (checked) {
                                  setModalState(() {
                                    if (checked == true) {
                                      selected.add(igloo.id);
                                    } else {
                                      selected.remove(igloo.id);
                                    }
                                  });
                                },
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _approveUser(entry, selected.toList());
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        "Today's Login",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white38,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            children: [
                              TabBar(
                                controller: _tabs,
                                labelColor: const Color(0xFF014576),
                                indicatorColor: const Color(0xFF5E9BC8),
                                tabs: [
                                  Tab(text: 'Pending (${_pendingUsers.length})'),
                                  Tab(text: 'Active (${_activeUsers.length})'),
                                ],
                              ),
                              const SizedBox(height: 12),
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
      child: _pendingUsers.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text('No users waiting for approval.')),
              ],
            )
          : ListView.builder(
              itemCount: _pendingUsers.length,
              itemBuilder: (context, index) {
                final entry = _pendingUsers[index];
                return _PendingUserCard(
                  entry: entry,
                  onApprove: () => _showApproveDialog(entry),
                  onReject: () => _rejectUser(entry),
                );
              },
            ),
    );
  }

  Widget _buildActiveTab() {
    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: _activeUsers.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text('No active users to display.')),
              ],
            )
          : ListView.builder(
              itemCount: _activeUsers.length,
              itemBuilder: (context, index) {
                final entry = _activeUsers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(entry.displayName),
                    subtitle: Text('${entry.userType.toUpperCase()} • ${entry.email}'),
                  ),
                );
              },
            ),
    );
  }
}

class _PendingUserCard extends StatelessWidget {
  final AdminUserEntry entry;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _PendingUserCard({
    required this.entry,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final business = entry.data['business_name']?.toString() ?? '-';
    final category = entry.data['business_category']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.6),
            Colors.white.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                Container(
                  padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                        gradient: LinearGradient(
                      colors: [Color(0xFF70A9EE), Color(0xFF97DCEB)],
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                            entry.displayName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF014576),
                        ),
                      ),
                      const SizedBox(height: 4),
                          Text(entry.email),
                          const SizedBox(height: 4),
                          Text(entry.userType.toUpperCase()),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Business: $business'),
                if (category != null) Text('Category: $category'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
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
