import 'package:flutter/material.dart';
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
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text('Enable Module'),
                subtitle: Text('Choose a module to enable for this user type'),
              ),
              ...available.map(
                (module) => ListTile(
                  leading: const Icon(Icons.extension),
                  title: Text(module.name),
                  subtitle: Text(
                    module.description.isEmpty
                        ? module.slug
                        : module.description,
                  ),
                  onTap: () => Navigator.pop(context, module),
                ),
              ),
            ],
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Module Access Management'),
        bottom: TabBar(
          controller: _tabs,
          tabs: _userTypes
              .map((type) => Tab(text: type.toUpperCase()))
              .toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showModulePicker(currentUserType),
        child: const Icon(Icons.add),
      ),
      body: _loading && !_modulesByUserType.containsKey(currentUserType)
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabs,
              children: _userTypes.map((userType) {
                final modules = _modulesByUserType[userType];
                final states = _moduleStates[userType];
                if (modules == null || states == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (modules.isEmpty) {
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
                        title: 'Enabled Modules (${enabledModules.length})',
                        modules: enabledModules,
                        states: states,
                        userType: userType,
                        emptyText: 'No modules enabled.',
                      ),
                      const SizedBox(height: 24),
                      _buildModuleSection(
                        title: 'Disabled Modules (${disabledModules.length})',
                        modules: disabledModules,
                        states: states,
                        userType: userType,
                        emptyText: 'No modules disabled.',
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildBulkActions(
    String userType,
    List<AdminModule> enabled,
    List<AdminModule> disabled,
  ) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: disabled.isEmpty
                ? null
                : () => _bulkUpdate(userType, disabled, true),
            icon: const Icon(Icons.playlist_add_check),
            label: const Text('Enable All'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: enabled.isEmpty
                ? null
                : () => _bulkUpdate(userType, enabled, false),
            icon: const Icon(Icons.block),
            label: const Text('Disable All'),
          ),
        ),
      ],
    );
  }

  Widget _buildModuleSection({
    required String title,
    required List<AdminModule> modules,
    required Map<int, bool> states,
    required String userType,
    required String emptyText,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (modules.isEmpty)
              Text(emptyText)
            else
              ...modules.map((module) {
                final enabled = states[module.id] ?? module.isEnabled;
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(module.name),
                  subtitle: Text(
                    module.description.isEmpty
                        ? module.slug
                        : module.description,
                  ),
                  value: enabled,
                  onChanged: (value) => _toggleModule(userType, module, value),
                );
              }),
          ],
        ),
      ),
    );
  }
}
