import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/Data/Models/admin_module.dart';
import 'package:snow_app/Data/Repositories/admin_repository.dart';
import 'package:snow_app/core/app_toast.dart';
import 'package:snow_app/core/result.dart';

class AdminModuleScreen extends StatefulWidget {
  const AdminModuleScreen({super.key});

  @override
  State<AdminModuleScreen> createState() => _AdminModuleScreenState();
}

class _AdminModuleScreenState extends State<AdminModuleScreen>
    with SingleTickerProviderStateMixin {
  final AdminRepository _repo = AdminRepository();

  final List<String> _userTypes = ['elite', 'visitor'];
  late final TabController _tabs;
  String? _bulkSelected;

  bool _loading = false;
  final Map<String, List<AdminModule>> _modulesByUserType = {};
  final Map<String, Map<int, bool>> _moduleStates = {};
  List<AdminModule> _allModules = const [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _userTypes.length, vsync: this);
    _tabs.addListener(() {
      if (_tabs.indexIsChanging) return;
      final userType = _userTypes[_tabs.index];
      if (!_modulesByUserType.containsKey(userType)) {
        _loadModules(userType);
      }
    });
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      _repo.fetchModules(),
      _repo.fetchModules(userType: _userTypes.first),
    ]);
    if (!mounted) return;

    switch (results[0]) {
      case Ok(value: final list):
        _allModules = list;
      case Err(message: final msg, code: final code):
        final suffix = code > 0 ? ' ($code)' : '';
        context.showToast(
          'Failed to load modules$suffix: $msg',
          bg: Colors.red,
        );
    }

    switch (results[1]) {
      case Ok(value: final list):
        _modulesByUserType[_userTypes.first] = list;
        _moduleStates[_userTypes.first] = {
          for (final module in list) module.id: module.isEnabled,
        };
      case Err(message: final msg, code: final code):
        final suffix = code > 0 ? ' ($code)' : '';
        context.showToast('Module list failed$suffix: $msg', bg: Colors.red);
    }

    setState(() => _loading = false);
  }

  Future<void> _loadModules(String userType) async {
    setState(() => _loading = true);
    final res = await _repo.fetchModules(userType: userType);
    if (!mounted) return;
    switch (res) {
      case Ok(value: final modules):
        _modulesByUserType[userType] = modules;
        _moduleStates[userType] = {
          for (final module in modules) module.id: module.isEnabled,
        };
        setState(() => _loading = false);
      case Err(message: final msg, code: final code):
        setState(() => _loading = false);
        final suffix = code > 0 ? ' ($code)' : '';
        context.showToast('Module list failed$suffix: $msg', bg: Colors.red);
    }
  }

  Future<void> _toggleModule(
    String userType,
    AdminModule module,
    bool value,
  ) async {
    final previousState = _moduleStates[userType]?[module.id];
    final hadModule =
        _modulesByUserType[userType]?.any((m) => m.id == module.id) ?? false;

    if (!hadModule) {
      (_modulesByUserType[userType] ??= []).add(module);
    }

    setState(() => (_moduleStates[userType] ??= {})[module.id] = value);

    final res = await _repo.updateModuleAccess(
      userType: userType,
      moduleId: module.id,
      isEnabled: value,
    );

    if (!mounted) return;

    switch (res) {
      case Ok():
        context.showToast(
          '${module.name} ${value ? 'enabled' : 'disabled'} for $userType',
        );
      case Err(message: final msg, code: final code):
        final suffix = code > 0 ? ' ($code)' : '';
        context.showToast('Update failed$suffix: $msg', bg: Colors.red);
        if (previousState == null) {
          setState(() {
            _moduleStates[userType]?.remove(module.id);
            if (!hadModule) {
              _modulesByUserType[userType]?.removeWhere(
                (m) => m.id == module.id,
              );
            }
          });
        } else {
          setState(() => _moduleStates[userType]?[module.id] = previousState);
        }
    }
  }

  Future<void> _bulkUpdate(
    String userType,
    Iterable<AdminModule> modules,
    bool enable,
  ) async {
    for (final module in modules) {
      final current = _moduleStates[userType]?[module.id] ?? module.isEnabled;
      if (current == enable) continue;
      await _toggleModule(userType, module, enable);
    }
  }

  Future<void> _showModulePicker(String userType) async {
    final res = await _repo.fetchModules();
    switch (res) {
      case Ok(value: final modules):
        _allModules = modules;
      case Err(message: final msg, code: final code):
        final suffix = code > 0 ? ' ($code)' : '';
        context.showToast(
          'Failed to load module list$suffix: $msg',
          bg: Colors.red,
        );
        return;
    }

    if (_allModules.isEmpty) {
      context.showToast('No modules available to assign', bg: Colors.orange);
      return;
    }

    final states = _moduleStates[userType] ?? {};
    final available = _allModules
        .where((module) => !(states[module.id] ?? module.isEnabled))
        .toList();

    if (available.isEmpty) {
      context.showToast('All modules already enabled for $userType');
      return;
    }

    final selected = await showModalBottomSheet<AdminModule>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(26),
              topRight: Radius.circular(26),
            ),
            border: Border.all(color: Colors.white70),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  Text(
                    "Enable Module",
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF014576),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Choose a module to enable for this user type",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: available.map((module) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.white.withOpacity(0.65),
                            border: Border.all(color: Colors.white70),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => Navigator.pop(context, module),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF5E9BC8,
                                      ).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.extension,
                                      color: Color(0xFF5E9BC8),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          module.name,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF2E4A64),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          module.description.isEmpty
                                              ? module.slug
                                              : module.description,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12.5,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (selected != null) {
      await _toggleModule(userType, selected, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserType = _userTypes[_tabs.index];
    const Color primaryBlue = Color(0xFF5E9BC8);
    const Color textColor = Color(0xFF2E4A64);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showModulePicker(currentUserType),
        backgroundColor: Colors.white.withOpacity(0.85),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.7)),
        ),
        child: const Icon(Icons.add, color: Color(0xFF014576), size: 26),
      ),
      body: Stack(
        children: [
          // Background Layer
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

          // Content Layer
          SafeArea(
            child: Column(
              children: [
                // 1. Header Row
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF014576),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          "Module Access Management",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF014576),
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Tab Bar Section
                Container(
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 22),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white30),
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
                      insets: const EdgeInsets.symmetric(horizontal: 40),
                    ),
                    labelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14.5,
                    ),
                    tabs: _userTypes
                        .map((type) => Tab(text: type.toUpperCase()))
                        .toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // 3. Tab Bar View (The Scrollable List Area)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.45),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child:
                        _loading &&
                            !_modulesByUserType.containsKey(currentUserType)
                        ? const Center(child: CircularProgressIndicator())
                        : TabBarView(
                            controller: _tabs,
                            children: _userTypes.map((userType) {
                              final modules = _modulesByUserType[userType];
                              final states = _moduleStates[userType];

                              if (modules == null || states == null) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (modules.isEmpty) {
                                return _buildEmptyState(userType);
                              }

                              final enabledModules = modules
                                  .where((m) => states[m.id] ?? m.isEnabled)
                                  .toList();
                              final disabledModules = modules
                                  .where((m) => !(states[m.id] ?? m.isEnabled))
                                  .toList();

                              return RefreshIndicator(
                                onRefresh: () => _loadModules(userType),
                                child: ListView(
                                  padding: const EdgeInsets.all(16),
                                  children: [
                                    _buildBulkActions(
                                      userType,
                                      enabledModules,
                                      disabledModules,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildModuleSection(
                                      title:
                                          'Enabled Modules (${enabledModules.length})',
                                      modules: enabledModules,
                                      states: states,
                                      userType: userType,
                                      emptyText: 'No modules enabled.',
                                    ),
                                    const SizedBox(height: 24),
                                    _buildModuleSection(
                                      title:
                                          'Disabled Modules (${disabledModules.length})',
                                      modules: disabledModules,
                                      states: states,
                                      userType: userType,
                                      emptyText: 'No modules disabled.',
                                    ),
                                    const SizedBox(height: 80), // FAB spacing
                                  ],
                                ),
                              );
                            }).toList(),
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

  Widget _buildEmptyState(String userType) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No modules assigned yet.'),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _showModulePicker(userType),
              icon: const Icon(Icons.add),
              label: const Text('Assign Module'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulkActions(
    String userType,
    List<AdminModule> enabled,
    List<AdminModule> disabled,
  ) {
    const activeColor = Colors.white;
    const borderColor = Color(0xFFCBD5E1);
    const textColor = Color(0xFF2E4A64);

    final bool enableActive = _bulkSelected == "enable";
    final bool disableActive = _bulkSelected == "disable";

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: disabled.isEmpty
                ? null
                : () {
                    setState(() => _bulkSelected = "enable");
                    _bulkUpdate(userType, disabled, true);
                  },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: enableActive
                  ? activeColor
                  : Colors.white.withOpacity(0.7),
              foregroundColor: textColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: enableActive
                      ? borderColor
                      : borderColor.withOpacity(0.6),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.playlist_add_check,
                  size: 18,
                  color: textColor.withOpacity(0.8),
                ),
                const SizedBox(width: 6),
                Text(
                  "Enable All",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: enabled.isEmpty
                ? null
                : () {
                    setState(() => _bulkSelected = "disable");
                    _bulkUpdate(userType, enabled, false);
                  },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: disableActive
                  ? activeColor
                  : Colors.white.withOpacity(0.7),
              foregroundColor: textColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: disableActive
                      ? borderColor
                      : borderColor.withOpacity(0.6),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.block, size: 18, color: textColor.withOpacity(0.7)),
                const SizedBox(width: 6),
                Text(
                  "Disable All",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget glassModuleCard({required Widget child}) {
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
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    );
  }

  Widget _buildModuleSection({
    required String title,
    required List<AdminModule> modules,
    required Map<int, bool> states,
    required String userType,
    required String emptyText,
  }) {
    const textColor = Color(0xFF2E4A64);

    return glassModuleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 14),
          if (modules.isEmpty)
            Text(
              emptyText,
              style: GoogleFonts.poppins(fontSize: 13.5, color: textColor),
            )
          else
            ...modules.map((module) {
              final enabled = states[module.id] ?? module.isEnabled;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white.withOpacity(0.65),
                  border: Border.all(color: Colors.white70),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5E9BC8).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.extension,
                        color: Color(0xFF5E9BC8),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            module.name,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.5,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            module.description.isEmpty
                                ? module.slug
                                : module.description,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: enabled,
                      activeColor: const Color(0xFF5E9BC8),
                      activeTrackColor: const Color(
                        0xFF5E9BC8,
                      ).withOpacity(0.4),
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey.withOpacity(0.35),
                      onChanged: (value) =>
                          _toggleModule(userType, module, value),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
