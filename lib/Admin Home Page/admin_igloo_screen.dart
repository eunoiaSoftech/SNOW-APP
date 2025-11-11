import 'package:flutter/material.dart';
import 'package:snow_app/Data/Models/admin_igloo.dart';
import 'package:snow_app/Data/Models/location_option.dart';
import 'package:snow_app/Data/Repositories/admin_repository.dart';
import 'package:snow_app/Data/Repositories/common_repository.dart';
import 'package:snow_app/core/app_toast.dart';
import 'package:snow_app/core/result.dart';

class AdminIglooScreen extends StatefulWidget {
  const AdminIglooScreen({super.key});

  @override
  State<AdminIglooScreen> createState() => _AdminIglooScreenState();
}

class _AdminIglooScreenState extends State<AdminIglooScreen> {
  final AdminRepository _adminRepo = AdminRepository();
  final CommonRepository _commonRepo = CommonRepository();

  bool _loading = true;
  bool _savingIgloo = false;

  List<Igloo> _igloos = [];
  List<CountryOption> _countries = [];

  final TextEditingController _iglooName = TextEditingController();
  final TextEditingController _meetingTime = TextEditingController(text: '10:30');
  final TextEditingController _notes = TextEditingController();

  CountryOption? _selectedCountry;
  ZoneOption? _selectedZone;
  StateOption? _selectedState;
  CityOption? _selectedCity;
  String _durationType = 'weekly';
  String _meetingMode = 'online';

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _iglooName.dispose();
    _meetingTime.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    setState(() => _loading = true);
    await Future.wait([
      _loadIgloos(),
      _loadLocations(),
    ]);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadLocations() async {
    final res = await _commonRepo.fetchLocations();
    if (!mounted) return;
    switch (res) {
      case Ok(value: final list):
        setState(() => _countries = list);
      case Err(message: final msg, code: _):
        context.showToast('Location load failed: $msg', bg: Colors.red);
    }
  }

  Future<void> _loadIgloos() async {
    final res = await _adminRepo.fetchIgloos();
    if (!mounted) return;
    switch (res) {
      case Ok(value: final list):
        setState(() => _igloos = list);
      case Err(message: final msg, code: _):
        context.showToast('Igloo load failed: $msg', bg: Colors.red);
    }
  }

  Future<void> _createIgloo() async {
    if (_iglooName.text.trim().isEmpty) {
      context.showToast('Enter igloo name');
      return;
    }
    if (_selectedCountry == null ||
        _selectedZone == null ||
        _selectedState == null ||
        _selectedCity == null) {
      context.showToast('Select full location');
      return;
    }
    setState(() => _savingIgloo = true);
    final payload = {
      'name': _iglooName.text.trim(),
      'country_id': _selectedCountry!.id,
      'zone_id': _selectedZone!.id,
      'state_id': _selectedState!.id,
      'city_id': _selectedCity!.id,
      'meeting_time': _meetingTime.text.trim(),
      'duration_type': _durationType,
      'mode': _meetingMode,
      'notes': _notes.text.trim(),
    };
    final res = await _adminRepo.createIgloo(payload);
    if (!mounted) return;
    setState(() => _savingIgloo = false);
    switch (res) {
      case Ok(value: final igloo):
        context.showToast('Igloo "${igloo.name}" created');
        _iglooName.clear();
        _notes.clear();
        await _loadIgloos();
      case Err(message: final msg, code: _):
        context.showToast('Create failed: $msg', bg: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Igloo Management'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadIgloos,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildIglooForm(),
                  const SizedBox(height: 24),
                  Text(
                    'Existing Igloos (${_igloos.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  if (_igloos.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No igloos created yet.'),
                      ),
                    )
                  else
                    ..._igloos.map(_buildIglooTile),
                ],
              ),
            ),
    );
  }

  Widget _buildIglooForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Igloo',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _iglooName,
              decoration: const InputDecoration(
                labelText: 'Igloo Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _meetingTime,
                    decoration: const InputDecoration(
                      labelText: 'Meeting Time (HH:mm)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _durationType,
                    decoration: const InputDecoration(
                      labelText: 'Frequency',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'daily', child: Text('Daily')),
                      DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                      DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                    ],
                    onChanged: (value) => setState(() => _durationType = value ?? 'weekly'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _meetingMode,
              decoration: const InputDecoration(
                labelText: 'Meeting Mode',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'online', child: Text('Online')),
                DropdownMenuItem(value: 'offline', child: Text('Offline')),
                DropdownMenuItem(value: 'hybrid', child: Text('Hybrid')),
              ],
              onChanged: (value) => setState(() => _meetingMode = value ?? 'online'),
            ),
            const SizedBox(height: 12),
            _locationDropdown<CountryOption>(
              label: 'Country',
              value: _selectedCountry,
              items: _countries,
              display: (c) => c.name,
              onChanged: (country) {
                setState(() {
                  _selectedCountry = country;
                  _selectedZone = null;
                  _selectedState = null;
                  _selectedCity = null;
                });
              },
            ),
            const SizedBox(height: 12),
            _locationDropdown<ZoneOption>(
              label: 'Zone',
              value: _selectedZone,
              items: _selectedCountry?.zones ?? const <ZoneOption>[],
              display: (z) => z.name,
              onChanged: (zone) {
                setState(() {
                  _selectedZone = zone;
                  _selectedState = null;
                  _selectedCity = null;
                });
              },
            ),
            const SizedBox(height: 12),
            _locationDropdown<StateOption>(
              label: 'State',
              value: _selectedState,
              items: _selectedZone?.states ?? const <StateOption>[],
              display: (s) => s.name,
              onChanged: (state) {
                setState(() {
                  _selectedState = state;
                  _selectedCity = null;
                });
              },
            ),
            const SizedBox(height: 12),
            _locationDropdown<CityOption>(
              label: 'City',
              value: _selectedCity,
              items: _selectedState?.cities ?? const <CityOption>[],
              display: (c) => c.name,
              onChanged: (city) => setState(() => _selectedCity = city),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _savingIgloo ? null : _createIgloo,
                icon: _savingIgloo
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.add),
                label: const Text('Create Igloo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIglooTile(Igloo igloo) {
    final subtitle = [
      if (igloo.countryName != null) igloo.countryName,
      if (igloo.zoneName != null) igloo.zoneName,
      if (igloo.stateName != null) igloo.stateName,
      if (igloo.cityName != null) igloo.cityName,
    ].whereType<String>().join(' • ');
    return Card(
      child: ListTile(
        title: Text(igloo.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subtitle.isNotEmpty) Text(subtitle),
            Text('${igloo.durationType.toUpperCase()} • ${igloo.mode.toUpperCase()} • ${igloo.meetingTime}'),
            Text('Assignments: ${igloo.assignments.length}'),
          ],
        ),
      ),
    );
  }

  DropdownButtonFormField<T> _locationDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T value) display,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: items.contains(value) ? value : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(display(item)),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
