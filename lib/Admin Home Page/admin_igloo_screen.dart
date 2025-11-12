import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/Data/Models/admin_igloo.dart';
import 'package:snow_app/Data/Models/location_option.dart';
import 'package:snow_app/Data/Repositories/admin_repository.dart';
import 'package:snow_app/Data/Repositories/common_repository.dart';
import 'package:snow_app/core/app_toast.dart';
import 'package:snow_app/core/result.dart';
import 'igloo_list_screen.dart';

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
  final TextEditingController _meetingTime =
      TextEditingController(text: '10:30');
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
    return Stack(
      children: [
        // Background gradient
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
            // centerTitle: true,
            title: Text(
              "Igloo Management",
              style: GoogleFonts.poppins(
                color: const Color(0xFF014576),
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            iconTheme: const IconThemeData(color: Color(0xFF014576)),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: const Icon(Icons.info,
                      color: Color(0xFF014576),size:24,),
                  tooltip: "View Existing Igloos",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              IglooListScreen(igloos: _igloos)),
                    );
                  },
                ),
              ),
            ],
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
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
                    child: _buildIglooForm(),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildIglooForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Igloo',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: const Color(0xFF014576),
          ),
        ),
        const SizedBox(height: 22),

        _inputField('Igloo Name', controller: _iglooName),
        const SizedBox(height: 18),

        Row(
          children: [
            Expanded(
              child: _inputField('Meeting Time (HH:mm)',
                  controller: _meetingTime),
            ),
            const SizedBox(width: 16),
            
            Expanded(
              child: _dropdownField<String>(
                label: 'Frequency',
                value: _durationType,
                items: const ['daily', 'weekly', 'monthly'],
                onChanged: (v) =>
                    setState(() => _durationType = v ?? 'weekly'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        _dropdownField<String>(
          label: 'Meeting Mode',
          value: _meetingMode,
          items: const ['online', 'offline', 'hybrid'],
          onChanged: (v) => setState(() => _meetingMode = v ?? 'online'),
        ),
                const SizedBox(height: 18),

        _dropdownField<CountryOption>(
          label: 'Country',
          value: _selectedCountry,
          items: _countries,
          display: (c) => c.name,
          onChanged: (c) {
            setState(() {
              _selectedCountry = c;
              _selectedZone = _selectedState = _selectedCity = null;
            });
          },
        ),
        const SizedBox(height: 18),
        _dropdownField<ZoneOption>(
          label: 'Zone',
          value: _selectedZone,
          items: _selectedCountry?.zones ?? const <ZoneOption>[],
          display: (z) => z.name,
          onChanged: (z) {
            setState(() {
              _selectedZone = z;
              _selectedState = _selectedCity = null;
            });
          },
        ),
        const SizedBox(height: 18),
        _dropdownField<StateOption>(
          label: 'State',
          value: _selectedState,
          items: _selectedZone?.states ?? const <StateOption>[],
          display: (s) => s.name,
          onChanged: (s) {
            setState(() {
              _selectedState = s;
              _selectedCity = null;
            });
          },
        ),
        const SizedBox(height: 18),
        _dropdownField<CityOption>(
          label: 'City',
          value: _selectedCity,
          items: _selectedState?.cities ?? const <CityOption>[],
          display: (c) => c.name,
          onChanged: (c) => setState(() => _selectedCity = c),
        ),
        const SizedBox(height: 18),

        _inputField('Notes (optional)',
            controller: _notes, maxLines: 4, minLines: 2),
        const SizedBox(height: 24),

        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: _savingIgloo ? null : _createIgloo,
            icon: _savingIgloo
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child:
                        CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.add_circle_outline_rounded),
            label: const Text('Create Igloo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF014576),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _inputField(String label,
      {required TextEditingController controller,
      int minLines = 1,
      int maxLines = 1}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: TextField(
        controller: controller,
        minLines: minLines,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
              fontSize: 14, color: const Color(0xFF014576)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF5E9BC8), width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF014576), width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _dropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String Function(T)? display,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withOpacity(0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.blueGrey.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: DropdownButtonFormField<T>(
          value: items.contains(value) ? value : null,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.poppins(
                fontSize: 14, color: const Color(0xFF014576)),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          dropdownColor: Colors.white,
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      display != null ? display(item) : item.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF014576),
                      ),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
