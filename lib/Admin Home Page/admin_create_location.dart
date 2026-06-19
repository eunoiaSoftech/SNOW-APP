import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/Data/Repositories/common_repository.dart';
import 'package:snow_app/Data/models/location_option.dart';
import 'package:snow_app/common api/admin_location_repository.dart';
import 'package:snow_app/Data/models/New Model/admin_loactions_model.dart';
import 'package:snow_app/core/result.dart';

class AdminCreateLocationScreen extends StatefulWidget {
  const AdminCreateLocationScreen({super.key});

  @override
  State<AdminCreateLocationScreen> createState() =>
      _AdminCreateLocationScreenState();
}

class _AdminCreateLocationScreenState extends State<AdminCreateLocationScreen> {
  final AdminLocationRepository _repo = AdminLocationRepository();
  final CommonRepository _commonRepo = CommonRepository();

  final TextEditingController _country = TextEditingController();
  final TextEditingController _countryCode = TextEditingController();
  final TextEditingController _zone = TextEditingController();
  final TextEditingController _zoneCode = TextEditingController();
  final TextEditingController _state = TextEditingController();
  final TextEditingController _stateCode = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _cityCode = TextEditingController();

  /// Full hierarchy from `location/list` (country → zones → states → cities).
  List<CountryOption> _tree = [];

  List<AdminCountry> countries = [];
  List<AdminZone> zones = [];
  List<AdminState> states = [];
  List<AdminCity> cities = [];

  AdminCountry? selectedCountry;
  AdminZone? selectedZone;
  AdminState? selectedState;

  bool loadingCountry = false;
  bool loadingZone = false;
  bool loadingState = false;
  bool loadingCity = false;
  bool _loadingTree = false;

  @override
  void initState() {
    super.initState();
    _loadLocationTree();
  }

  @override
  void dispose() {
    _country.dispose();
    _countryCode.dispose();
    _zone.dispose();
    _zoneCode.dispose();
    _state.dispose();
    _stateCode.dispose();
    _city.dispose();
    _cityCode.dispose();
    super.dispose();
  }

  void _showMsg(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins()),
        backgroundColor: error ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  String _cleanError(Object e) {
    final raw = e.toString();
    final clean = raw
        .replaceAll('Exception:', '')
        .replaceAll('Error:', '')
        .replaceAll(RegExp(r'\b\d{3}\b'), '')
        .trim();
    return clean.isEmpty ? 'Something went wrong. Please try again.' : clean;
  }

  String? _optionalCode(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  bool _existsIgnoreCase<T>(
      List<T> list,
      String name,
      String Function(T) getName,
      ) {
    return list.any(
          (item) => getName(item).toLowerCase() == name.toLowerCase(),
    );
  }

  CountryOption? _countryNode(int id) {
    for (final c in _tree) {
      if (c.id == id) return c;
    }
    return null;
  }

  void _syncZonesFromTree() {
    zones = [];
    states = [];
    cities = [];
    selectedZone = null;
    selectedState = null;
    final node = selectedCountry == null
        ? null
        : _countryNode(selectedCountry!.id);
    if (node == null) return;
    zones = node.zones
        .map((z) => AdminZone(id: z.id, name: z.name, parentId: node.id))
        .toList();
  }

  void _syncStatesFromTree() {
    states = [];
    cities = [];
    selectedState = null;
    final cNode = selectedCountry == null
        ? null
        : _countryNode(selectedCountry!.id);
    if (cNode == null || selectedZone == null) return;
    ZoneOption? zNode;
    for (final z in cNode.zones) {
      if (z.id == selectedZone!.id) {
        zNode = z;
        break;
      }
    }
    if (zNode == null) return;
    final z = zNode;
    states = z.states
        .map(
          (s) => AdminState(
        id: s.id,
        name: s.name,
        countryId: z.id,
      ),
    )
        .toList();
  }

  void _syncCitiesFromTree() {
    cities = [];
    final cNode = selectedCountry == null
        ? null
        : _countryNode(selectedCountry!.id);
    if (cNode == null || selectedZone == null || selectedState == null) {
      return;
    }
    ZoneOption? zNode;
    for (final z in cNode.zones) {
      if (z.id == selectedZone!.id) {
        zNode = z;
        break;
      }
    }
    if (zNode == null) return;
    StateOption? sNode;
    for (final s in zNode.states) {
      if (s.id == selectedState!.id) {
        sNode = s;
        break;
      }
    }
    if (sNode == null) return;
    final st = sNode;
    cities = st.cities
        .map(
          (city) => AdminCity(
        id: city.id,
        name: city.name,
        countryId: cNode.id,
        stateId: st.id,
      ),
    )
        .toList();
  }

  /// Reload tree from API and optionally restore dropdown selections by id.
  Future<void> _loadLocationTree({
    int? keepCountryId,
    int? keepZoneId,
    int? keepStateId,
  }) async {
    setState(() => _loadingTree = true);
    final res = await _commonRepo.fetchLocations();
    if (!mounted) return;

    switch (res) {
      case Ok(value: final list):
        _tree = list;
        countries = list
            .map((c) => AdminCountry(id: c.id, name: c.name))
            .toList();

        AdminCountry? nextCountry;
        if (keepCountryId != null) {
          for (final c in countries) {
            if (c.id == keepCountryId) {
              nextCountry = c;
              break;
            }
          }
        }
        selectedCountry = nextCountry;
        _syncZonesFromTree();

        AdminZone? nextZone;
        if (keepZoneId != null) {
          for (final z in zones) {
            if (z.id == keepZoneId) {
              nextZone = z;
              break;
            }
          }
        }
        selectedZone = nextZone;
        _syncStatesFromTree();

        AdminState? nextState;
        if (keepStateId != null) {
          for (final s in states) {
            if (s.id == keepStateId) {
              nextState = s;
              break;
            }
          }
        }
        selectedState = nextState;
        _syncCitiesFromTree();

        setState(() => _loadingTree = false);
        break;

      case Err(message: final msg, code: _):
        setState(() => _loadingTree = false);
        _showMsg('Failed to load locations: $msg', error: true);
        break;
    }
  }

  Future<void> addCountry() async {
    final name = _country.text.trim();
    if (name.isEmpty) return _showMsg('Enter country name', error: true);

    if (_existsIgnoreCase(countries, name, (c) => c.name)) {
      return _showMsg('Country "$name" already exists', error: true);
    }

    setState(() => loadingCountry = true);
    try {
      await _repo.createCountry(
        name,
        locationCode: _optionalCode(_countryCode),
      );
      _country.clear();
      _countryCode.clear();
      _showMsg('Country "$name" added');
      await _loadLocationTree();
    } catch (e) {
      _showMsg(_cleanError(e), error: true);
    }
    setState(() => loadingCountry = false);
  }

  Future<void> deleteCountry(AdminCountry c) async {
    try {
      await _repo.deleteLocation(c.id);
      if (selectedCountry?.id == c.id) {
        selectedCountry = null;
        zones = [];
        states = [];
        cities = [];
        selectedZone = null;
        selectedState = null;
      }
      _showMsg('Country deleted');
      await _loadLocationTree(
        keepCountryId: selectedCountry?.id,
        keepZoneId: selectedZone?.id,
        keepStateId: selectedState?.id,
      );
    } catch (e) {
      _showMsg(_cleanError(e), error: true);
    }
  }

  Future<void> addZone() async {
    final name = _zone.text.trim();
    if (name.isEmpty) return _showMsg('Enter zone name', error: true);
    if (selectedCountry == null) {
      return _showMsg('Select country first', error: true);
    }

    if (_existsIgnoreCase(zones, name, (z) => z.name)) {
      return _showMsg('Zone "$name" already exists under this country',
          error: true);
    }

    setState(() => loadingZone = true);
    try {
      await _repo.createZone(
        name,
        selectedCountry!.id,
        locationCode: _optionalCode(_zoneCode),
      );
      _zone.clear();
      _zoneCode.clear();
      _showMsg('Zone "$name" added');
      await _loadLocationTree(
        keepCountryId: selectedCountry!.id,
        keepZoneId: selectedZone?.id,
        keepStateId: selectedState?.id,
      );
    } catch (e) {
      _showMsg(_cleanError(e), error: true);
    }
    setState(() => loadingZone = false);
  }

  Future<void> deleteZone(AdminZone z) async {
    try {
      await _repo.deleteLocation(z.id);
      if (selectedZone?.id == z.id) {
        selectedZone = null;
        states = [];
        cities = [];
        selectedState = null;
      }
      _showMsg('Zone deleted');
      await _loadLocationTree(
        keepCountryId: selectedCountry?.id,
        keepZoneId: selectedZone?.id,
        keepStateId: selectedState?.id,
      );
    } catch (e) {
      _showMsg(_cleanError(e), error: true);
    }
  }

  Future<void> addState() async {
    final name = _state.text.trim();
    if (name.isEmpty) return _showMsg('Enter state name', error: true);
    if (selectedZone == null) {
      return _showMsg('Select zone first', error: true);
    }

    if (_existsIgnoreCase(states, name, (s) => s.name)) {
      return _showMsg('State "$name" already exists under this zone',
          error: true);
    }

    setState(() => loadingState = true);
    try {
      await _repo.createState(
        name,
        selectedZone!.id,
        locationCode: _optionalCode(_stateCode),
      );
      _state.clear();
      _stateCode.clear();
      _showMsg('State "$name" added');
      await _loadLocationTree(
        keepCountryId: selectedCountry?.id,
        keepZoneId: selectedZone!.id,
        keepStateId: selectedState?.id,
      );
    } catch (e) {
      _showMsg(_cleanError(e), error: true);
    }
    setState(() => loadingState = false);
  }

  Future<void> deleteState(AdminState s) async {
    try {
      await _repo.deleteLocation(s.id);
      if (selectedState?.id == s.id) {
        selectedState = null;
        cities = [];
      }
      _showMsg('State deleted');
      await _loadLocationTree(
        keepCountryId: selectedCountry?.id,
        keepZoneId: selectedZone?.id,
        keepStateId: selectedState?.id,
      );
    } catch (e) {
      _showMsg(_cleanError(e), error: true);
    }
  }

  Future<void> addCity() async {
    final name = _city.text.trim();
    if (name.isEmpty) return _showMsg('Enter city name', error: true);
    if (selectedState == null) {
      return _showMsg('Select state first', error: true);
    }

    if (_existsIgnoreCase(cities, name, (c) => c.name)) {
      return _showMsg('City "$name" already exists under this state',
          error: true);
    }

    setState(() => loadingCity = true);
    try {
      await _repo.createCity(
        name,
        selectedState!.id,
        locationCode: _optionalCode(_cityCode),
      );
      _city.clear();
      _cityCode.clear();
      _showMsg('City "$name" added');
      await _loadLocationTree(
        keepCountryId: selectedCountry?.id,
        keepZoneId: selectedZone?.id,
        keepStateId: selectedState!.id,
      );
    } catch (e) {
      _showMsg(_cleanError(e), error: true);
    }
    setState(() => loadingCity = false);
  }

  Future<void> deleteCity(AdminCity c) async {
    try {
      await _repo.deleteLocation(c.id);
      _showMsg('City deleted');
      await _loadLocationTree(
        keepCountryId: selectedCountry?.id,
        keepZoneId: selectedZone?.id,
        keepStateId: selectedState?.id,
      );
    } catch (e) {
      _showMsg(_cleanError(e), error: true);
    }
  }

  Future<void> _deleteCityOption(CityOption c) async {
    try {
      await _repo.deleteLocation(c.id);
      _showMsg('City deleted');
      await _loadLocationTree(
        keepCountryId: selectedCountry?.id,
        keepZoneId: selectedZone?.id,
        keepStateId: selectedState?.id,
      );
    } catch (e) {
      _showMsg(_cleanError(e), error: true);
    }
  }

  Widget _section({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(22),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF014576),
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _codeField(TextEditingController c, String hint) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _createInput({
    required TextEditingController controller,
    required TextEditingController codeController,
    required String codeHint,
    required VoidCallback onAdd,
    required bool loading,
    String hint = 'Enter name',
    Widget? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (prefix != null) prefix,
        if (prefix != null) const SizedBox(height: 10),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        // _codeField(codeController, codeHint),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: loading ? null : onAdd,
            icon: loading
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(Icons.add),
            label: const Text('Add'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF014576),
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _chipList<T>({
    required List<T> data,
    required String Function(T) label,
    required void Function(T) onDelete,
  }) {
    if (data.isEmpty) {
      return Text(
        'No items yet',
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.blueGrey[400]),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: data
          .map(
            (e) => Chip(
          label: Text(label(e), style: GoogleFonts.poppins(fontSize: 12)),
          backgroundColor: const Color(0xFFE3F3FE),
          deleteIcon: const Icon(Icons.close, size: 18),
          onDeleted: () => onDelete(e),
        ),
      )
          .toList(),
    );
  }

  Widget _hierarchyOverview() {
    if (_tree.isEmpty) {
      return Text(
        _loadingTree ? 'Loading…' : 'No locations yet. Add a country below.',
        style: GoogleFonts.poppins(fontSize: 13, color: Colors.blueGrey[600]),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _tree.map((country) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(12),
            child: ExpansionTile(
              key: PageStorageKey('loc-country-${country.id}'),
              title: Text(
                '${country.name} (${country.code})',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF014576),
                ),
              ),
              children: country.zones.map((zone) {
                return ExpansionTile(
                  key: PageStorageKey('loc-zone-${country.id}-${zone.id}'),
                  title: Text(
                    '${zone.name} (${zone.code})',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  children: zone.states.map((state) {
                    return ExpansionTile(
                      key: PageStorageKey(
                        'loc-state-${country.id}-${zone.id}-${state.id}',
                      ),
                      title: Text(
                        '${state.name} (${state.code})',
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: state.cities.isEmpty
                              ? Text(
                            'No cities',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.blueGrey[400],
                            ),
                          )
                              : Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: state.cities.map((city) {
                              return Chip(
                                label: Text(
                                  '${city.name} (${city.code})',
                                  style: GoogleFonts.poppins(fontSize: 11),
                                ),
                                deleteIcon: const Icon(Icons.close,
                                    size: 16),
                                onDeleted: () =>
                                    _deleteCityOption(city),
                                backgroundColor: const Color(0xFFE3F3FE),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        );
      }).toList(),
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
              'Locations',
              style: GoogleFonts.poppins(
                color: const Color(0xFF014576),
                fontWeight: FontWeight.w600,
              ),
            ),
            iconTheme: const IconThemeData(color: Color(0xFF014576)),
          ),
          body: RefreshIndicator(
            onRefresh: () => _loadLocationTree(
              keepCountryId: selectedCountry?.id,
              keepZoneId: selectedZone?.id,
              keepStateId: selectedState?.id,
            ),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _section(
                    title: 'Hierarchy (from server)',
                    child: _loadingTree && _tree.isEmpty
                        ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    )
                        : _hierarchyOverview(),
                  ),
                  _section(
                    title: 'Countries',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _createInput(
                          controller: _country,
                          codeController: _countryCode,
                          codeHint: 'Code (optional, e.g. IN)',
                          onAdd: addCountry,
                          loading: loadingCountry,
                          hint: 'Country name (e.g. India)',
                        ),
                        const SizedBox(height: 10),
                        _chipList<AdminCountry>(
                          data: countries,
                          label: (c) => c.name,
                          onDelete: deleteCountry,
                        ),
                      ],
                    ),
                  ),
                  _section(
                    title: 'Zones',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<AdminCountry>(
                          value: selectedCountry,
                          items: countries
                              .map(
                                (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.name),
                            ),
                          )
                              .toList(),
                          onChanged: countries.isEmpty
                              ? null
                              : (v) {
                            setState(() {
                              selectedCountry = v;
                              _syncZonesFromTree();
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Select country',
                            filled: true,
                            fillColor: Colors.white,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _createInput(
                          controller: _zone,
                          codeController: _zoneCode,
                          codeHint: 'Code (optional, e.g. W)',
                          onAdd: addZone,
                          loading: loadingZone,
                          hint: 'Zone name (e.g. West)',
                        ),
                        const SizedBox(height: 10),
                        _chipList<AdminZone>(
                          data: zones,
                          label: (z) => z.name,
                          onDelete: deleteZone,
                        ),
                      ],
                    ),
                  ),
                  _section(
                    title: 'States',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<AdminZone>(
                          value: selectedZone,
                          items: zones
                              .map(
                                (z) => DropdownMenuItem(
                              value: z,
                              child: Text(z.name),
                            ),
                          )
                              .toList(),
                          onChanged: zones.isEmpty
                              ? null
                              : (v) {
                            setState(() {
                              selectedZone = v;
                              _syncStatesFromTree();
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Select zone',
                            filled: true,
                            fillColor: Colors.white,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _createInput(
                          controller: _state,
                          codeController: _stateCode,
                          codeHint: 'Code (optional, e.g. M)',
                          onAdd: addState,
                          loading: loadingState,
                          hint: 'State name (e.g. Maharashtra)',
                        ),
                        const SizedBox(height: 10),
                        _chipList<AdminState>(
                          data: states,
                          label: (s) => s.name,
                          onDelete: deleteState,
                        ),
                      ],
                    ),
                  ),
                  _section(
                    title: 'Cities',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<AdminState>(
                          value: selectedState,
                          items: states
                              .map(
                                (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.name),
                            ),
                          )
                              .toList(),
                          onChanged: states.isEmpty
                              ? null
                              : (v) {
                            setState(() {
                              selectedState = v;
                              _syncCitiesFromTree();
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Select state',
                            filled: true,
                            fillColor: Colors.white,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _createInput(
                          controller: _city,
                          codeController: _cityCode,
                          codeHint: 'Code (optional, e.g. MU)',
                          onAdd: addCity,
                          loading: loadingCity,
                          hint: 'City name (e.g. Mumbai)',
                        ),
                        const SizedBox(height: 10),
                        _chipList<AdminCity>(
                          data: cities,
                          label: (c) => c.name,
                          onDelete: deleteCity,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
