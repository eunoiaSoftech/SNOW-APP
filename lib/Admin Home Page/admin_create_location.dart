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

  // Controllers
  final TextEditingController _country = TextEditingController();
  final TextEditingController _zone = TextEditingController();
  final TextEditingController _state = TextEditingController();
  final TextEditingController _city = TextEditingController();

  // Local lists (current session + loaded from backend)
  List<AdminCountry> countries = [];
  List<AdminZone> zones = [];
  List<AdminState> states = [];
  List<CountryOption> backendTree = [];


  // Selections
  AdminCountry? selectedCountry;
  AdminZone? selectedZone;
  AdminState? selectedState;

  // Loading flags
  bool loadingCountry = false;
  bool loadingZone = false;
  bool loadingState = false;
  bool loadingCity = false;

  @override
  void initState() {
    super.initState();
    _loadInitialCountries();
  }

  @override
  void dispose() {
    _country.dispose();
    _zone.dispose();
    _state.dispose();
    _city.dispose();
    super.dispose();
  }

  // ---------------- HELPERS ----------------

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

  bool _existsIgnoreCase<T>(
    List<T> list,
    String name,
    String Function(T) getName,
  ) {
    return list.any(
      (item) => getName(item).toLowerCase() == name.toLowerCase(),
    );
  }

  // ---------------- LOAD FROM BACKEND ----------------

  
  Future<void> _loadInitialCountries() async {
    final res = await _commonRepo.fetchLocations();
    if (!mounted) return;

    switch (res) {
      case Ok(value: final list):
        setState(() {
          // convert CountryOption → AdminCountry list
          countries = list
              .map((c) => AdminCountry(id: c.id, name: c.name))
              .toList();
        });

        break;

      case Err(message: final msg, code: _):
        _showMsg("Failed to load locations: $msg", error: true);
        break;
    }
  }

  // ---------------- CREATE + DELETE ----------------

  Future<void> addCountry() async {
    final name = _country.text.trim();
    if (name.isEmpty) return _showMsg("Enter country name", error: true);

    // IMPORTANT: now countries already has backend data → no duplicate India
    if (_existsIgnoreCase(countries, name, (c) => (c as AdminCountry).name)) {
      return _showMsg("Country \"$name\" already exists", error: true);
    }

    setState(() => loadingCountry = true);
    try {
      final c = await _repo.createCountry(name);
      setState(() => countries.add(c));
      _country.clear();
      _showMsg("Country \"$name\" added");
    } catch (e) {
      _showMsg(_cleanError(e), error: true);
    }
    setState(() => loadingCountry = false);
  }

  Future<void> deleteCountry(AdminCountry c) async {
    try {
      await _repo.deleteLocation(c.id);
      setState(() {
        countries.remove(c);
        if (selectedCountry?.id == c.id) {
          selectedCountry = null;
          zones.clear();
          states.clear();
          selectedZone = null;
          selectedState = null;
        }
      });
      _showMsg("Country deleted");
    } catch (e) {
      _showMsg(_cleanError(e), error: true);
    }
  }

  Future<void> addZone() async {
    final name = _zone.text.trim();
    if (name.isEmpty) return _showMsg("Enter zone name", error: true);
    if (selectedCountry == null) {
      return _showMsg("Select country first", error: true);
    }

    if (_existsIgnoreCase(zones, name, (z) => (z as AdminZone).name)) {
      return _showMsg("Zone \"$name\" already exists", error: true);
    }

    setState(() => loadingZone = true);
    try {
      final z = await _repo.createZone(name, selectedCountry!.id);
      setState(() => zones.add(z));
      _zone.clear();
      _showMsg("Zone \"$name\" added");
    } catch (e) {
      _showMsg(_cleanError(e), error: true);
    }
    setState(() => loadingZone = false);
  }

  Future<void> deleteZone(AdminZone z) async {
    try {
      await _repo.deleteLocation(z.id);
      setState(() {
        zones.remove(z);
        if (selectedZone?.id == z.id) {
          selectedZone = null;
          states.clear();
          selectedState = null;
        }
      });
      _showMsg("Zone deleted");
    } catch (e) {
      _showMsg(_cleanError(e), error: true);
    }
  }

  Future<void> addState() async {
    final name = _state.text.trim();
    if (name.isEmpty) return _showMsg("Enter state name", error: true);
    if (selectedZone == null) {
      return _showMsg("Select zone first", error: true);
    }

    if (_existsIgnoreCase(states, name, (s) => (s as AdminState).name)) {
      return _showMsg("State \"$name\" already exists", error: true);
    }

    setState(() => loadingState = true);
    try {
      final s = await _repo.createState(name, selectedZone!.id);
      setState(() => states.add(s));
      _state.clear();
      _showMsg("State \"$name\" added");
    } catch (e) {
      _showMsg(_cleanError(e), error: true);
    }
    setState(() => loadingState = false);
  }

  Future<void> deleteState(AdminState s) async {
    try {
      await _repo.deleteLocation(s.id);
      setState(() {
        states.remove(s);
        if (selectedState?.id == s.id) {
          selectedState = null;
        }
      });
      _showMsg("State deleted");
    } catch (e) {
      _showMsg(_cleanError(e), error: true);
    }
  }

  Future<void> addCity() async {
    final name = _city.text.trim();
    if (name.isEmpty) return _showMsg("Enter city name", error: true);
    if (selectedState == null) {
      return _showMsg("Select state first", error: true);
    }

    setState(() => loadingCity = true);
    try {
      await _repo.createCity(name, selectedState!.id);
      _city.clear();
      _showMsg("City \"$name\" added");
    } catch (e) {
      _showMsg(_cleanError(e), error: true);
    }
    setState(() => loadingCity = false);
  }

  // ---------------- UI HELPERS ----------------

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

  Widget _createInput({
    required TextEditingController controller,
    required VoidCallback onAdd,
    required bool loading,
    String hint = "Enter name",
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
            label: const Text("Add"),
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
        "No items yet",
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

  // ---------------- BUILD ----------------

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background same style as category screen
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
              "Create Locations",
              style: GoogleFonts.poppins(
                color: const Color(0xFF014576),
                fontWeight: FontWeight.w600,
              ),
            ),
            iconTheme: const IconThemeData(color: Color(0xFF014576)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // COUNTRY
                _section(
                  title: "Countries",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _createInput(
                        controller: _country,
                        onAdd: addCountry,
                        loading: loadingCountry,
                        hint: "Enter country name (e.g. India)",
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

                // ZONE
                _section(
                  title: "Zones",
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
                        onChanged: (v) {
                          setState(() {
                            selectedCountry = v;
                            // optional: clear zones/states when country changes
                            zones.clear();
                            states.clear();
                            selectedZone = null;
                            selectedState = null;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: "Select country",
                          filled: true,
                          fillColor: Colors.white,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _createInput(
                        controller: _zone,
                        onAdd: addZone,
                        loading: loadingZone,
                        hint: "Enter zone name (e.g. West, South)",
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

                // STATE
                _section(
                  title: "States",
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
                        onChanged: (v) {
                          setState(() {
                            selectedZone = v;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: "Select zone",
                          filled: true,
                          fillColor: Colors.white,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _createInput(
                        controller: _state,
                        onAdd: addState,
                        loading: loadingState,
                        hint: "Enter state name (e.g. Gujarat)",
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

                // CITY
                _section(
                  title: "Cities",
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
                        onChanged: (v) {
                          setState(() {
                            selectedState = v;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: "Select state",
                          filled: true,
                          fillColor: Colors.white,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _createInput(
                        controller: _city,
                        onAdd: addCity,
                        loading: loadingCity,
                        hint: "Enter city name (e.g. Ahmedabad)",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:snow_app/Data/Repositories/common_repository.dart';
// import 'package:snow_app/Data/models/location_option.dart';
// import 'package:snow_app/common api/admin_location_repository.dart';
// import 'package:snow_app/Data/models/New Model/admin_loactions_model.dart';
// import 'package:snow_app/core/result.dart';

// class AdminCreateLocationScreen extends StatefulWidget {
//   const AdminCreateLocationScreen({super.key});

//   @override
//   State<AdminCreateLocationScreen> createState() =>
//       _AdminCreateLocationScreenState();
// }

// class _AdminCreateLocationScreenState extends State<AdminCreateLocationScreen> {
//   final AdminLocationRepository _repo = AdminLocationRepository();
//   final CommonRepository _commonRepo = CommonRepository();

//   // Controllers
//   final TextEditingController _country = TextEditingController();
//   final TextEditingController _zone = TextEditingController();
//   final TextEditingController _state = TextEditingController();
//   final TextEditingController _city = TextEditingController();

//   // Backend full hierarchy
//   List<CountryOption> backendTree = [];

//   // Flattened lists for chips
//   List<AdminCountry> countries = [];
//   List<AdminZone> zones = [];
//   List<AdminState> states = [];
//   List<String> cities = [];

//   // Selections
//   AdminCountry? selectedCountry;
//   AdminZone? selectedZone;
//   AdminState? selectedState;

//   // Loading flags
//   bool loadingCountry = false;
//   bool loadingZone = false;
//   bool loadingState = false;
//   bool loadingCity = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadInitialLocations();
//   }

//   @override
//   void dispose() {
//     _country.dispose();
//     _zone.dispose();
//     _state.dispose();
//     _city.dispose();
//     super.dispose();
//   }

//   Widget _createInput({
//     required TextEditingController controller,
//     required VoidCallback onAdd,
//     required bool loading,
//     String hint = "Enter name",
//     Widget? prefix,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (prefix != null) prefix,
//         if (prefix != null) const SizedBox(height: 10),
//         TextField(
//           controller: controller,
//           decoration: InputDecoration(
//             hintText: hint,
//             filled: true,
//             fillColor: Colors.white,
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//           ),
//         ),
//         const SizedBox(height: 10),
//         Align(
//           alignment: Alignment.centerRight,
//           child: ElevatedButton.icon(
//             onPressed: loading ? null : onAdd,
//             icon: loading
//                 ? const SizedBox(
//                     width: 18,
//                     height: 18,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       color: Colors.white,
//                     ),
//                   )
//                 : const Icon(Icons.add),
//             label: const Text("Add"),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF014576),
//               foregroundColor: Colors.white,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ---------------- HELPERS ----------------

//   void _showMsg(String msg, {bool error = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg, style: GoogleFonts.poppins()),
//         backgroundColor: error ? Colors.red.shade600 : Colors.green.shade600,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(12),
//       ),
//     );
//   }

//   String _cleanError(Object e) {
//     final raw = e.toString();
//     final clean = raw
//         .replaceAll('Exception:', '')
//         .replaceAll('Error:', '')
//         .replaceAll(RegExp(r'\b\d{3}\b'), '')
//         .trim();
//     return clean.isEmpty ? 'Something went wrong. Please try again.' : clean;
//   }

//   bool _existsIgnoreCase<T>(
//       List<T> list, String name, String Function(T) getName) {
//     return list.any(
//       (item) => getName(item).toLowerCase() == name.toLowerCase(),
//     );
//   }

//   // ---------------- LOAD BACKEND TREE ----------------

//   Future<void> _loadInitialLocations() async {
//     final res = await _commonRepo.fetchLocations();
//     if (!mounted) return;

//     switch (res) {
//       case Ok(value: final list):
//         backendTree = list; // IMPORTANT

//         setState(() {
//           countries = backendTree
//               .map((c) => AdminCountry(id: c.id, name: c.name))
//               .toList();
//         });

//         break;

//       case Err(message: final msg, code: _):
//         _showMsg("Failed to load locations: $msg", error: true);
//         break;
//     }
//   }

//   // ---------------- REBUILD ZONES AFTER COUNTRY SELECT ----------------

//   void _loadZonesForCountry() {
//     zones.clear();
//     states.clear();
//     cities.clear();
//     selectedZone = null;
//     selectedState = null;

//     if (selectedCountry == null) return;

//     final country =
//         backendTree.firstWhere((x) => x.id == selectedCountry!.id);

//     zones = country.zones
//         .map((z) => AdminZone(id: z.id, name: z.name, parentId: country.id))
//         .toList();

//     setState(() {});
//   }

//   // ---------------- REBUILD STATES AFTER ZONE SELECT ----------------

//   void _loadStatesForZone() {
//     states.clear();
//     cities.clear();
//     selectedState = null;

//     if (selectedCountry == null || selectedZone == null) return;

//     final country =
//         backendTree.firstWhere((x) => x.id == selectedCountry!.id);

//     final zone = country.zones.firstWhere((z) => z.id == selectedZone!.id);

//     states = zone.states
//         .map((s) =>
//             AdminState(id: s.id, name: s.name, countryId: selectedZone!.id))
//         .toList();

//     setState(() {});
//   }

//   // ---------------- REBUILD CITIES AFTER STATE SELECT ----------------

//   void _loadCitiesForState() {
//     cities.clear();

//     if (selectedCountry == null ||
//         selectedZone == null ||
//         selectedState == null) return;

//     final country =
//         backendTree.firstWhere((x) => x.id == selectedCountry!.id);

//     final zone = country.zones.firstWhere((z) => z.id == selectedZone!.id);

//     final state =
//         zone.states.firstWhere((s) => s.id == selectedState!.id);

//     cities = state.cities.map((c) => c.name).toList();

//     setState(() {});
//   }

//   // ---------------- CREATE + DELETE ----------------

//   Future<void> addCountry() async {
//     final name = _country.text.trim();

//     if (name.isEmpty) return _showMsg("Enter country name", error: true);

//     if (_existsIgnoreCase(countries, name, (c) => (c as AdminCountry).name)) {
//       return _showMsg("Country \"$name\" already exists", error: true);
//     }

//     setState(() => loadingCountry = true);

//     try {
//       final c = await _repo.createCountry(name);
//       setState(() => countries.add(c));
//       _country.clear();
//       _showMsg("Country \"$name\" added");
//     } catch (e) {
//       _showMsg(_cleanError(e), error: true);
//     }

//     setState(() => loadingCountry = false);
//   }

//   Future<void> addZone() async {
//     final name = _zone.text.trim();
//     if (name.isEmpty) return _showMsg("Enter zone name", error: true);
//     if (selectedCountry == null) {
//       return _showMsg("Select country first", error: true);
//     }

//     if (_existsIgnoreCase(zones, name, (z) => (z as AdminZone).name)) {
//       return _showMsg("Zone \"$name\" already exists", error: true);
//     }

//     setState(() => loadingZone = true);

//     try {
//       final z = await _repo.createZone(name, selectedCountry!.id);
//       zones.add(z);
//       _zone.clear();
//       _showMsg("Zone \"$name\" added");
//       setState(() {});
//     } catch (e) {
//       _showMsg(_cleanError(e), error: true);
//     }

//     setState(() => loadingZone = false);
//   }

//   Future<void> addState() async {
//     final name = _state.text.trim();
//     if (name.isEmpty) return _showMsg("Enter state name", error: true);
//     if (selectedZone == null) {
//       return _showMsg("Select zone first", error: true);
//     }

//     if (_existsIgnoreCase(states, name, (s) => (s as AdminState).name)) {
//       return _showMsg("State \"$name\" already exists", error: true);
//     }

//     setState(() => loadingState = true);

//     try {
//       final s = await _repo.createState(name, selectedZone!.id);
//       states.add(s);
//       _state.clear();
//       _showMsg("State \"$name\" added");
//       setState(() {});
//     } catch (e) {
//       _showMsg(_cleanError(e), error: true);
//     }

//     setState(() => loadingState = false);
//   }

//   Future<void> addCity() async {
//     final name = _city.text.trim();
//     if (name.isEmpty) return _showMsg("Enter city name", error: true);
//     if (selectedState == null) {
//       return _showMsg("Select state first", error: true);
//     }

//     if (_existsIgnoreCase(cities, name, (x) => x)) {
//       return _showMsg("City \"$name\" already exists", error: true);
//     }

//     setState(() => loadingCity = true);

//     try {
//       await _repo.createCity(name, selectedState!.id);
//       cities.add(name);
//       _city.clear();
//       _showMsg("City \"$name\" added");
//       setState(() {});
//     } catch (e) {
//       _showMsg(_cleanError(e), error: true);
//     }

//     setState(() => loadingCity = false);
//   }

//   // ---------------- UI HELPERS ----------------

//   Widget _section({required String title, required Widget child}) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 20),
//       padding: const EdgeInsets.all(22),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(24),
//         gradient: const LinearGradient(
//           colors: [Color(0xFFEAF5FC), Color(0xFFD8E7FA)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         boxShadow: const [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 10,
//             offset: Offset(2, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: GoogleFonts.poppins(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: const Color(0xFF014576),
//             ),
//           ),
//           const SizedBox(height: 20),
//           child,
//         ],
//       ),
//     );
//   }

//   Widget _chipList({
//     required List<String> data,
//     required void Function(String) onDelete,
//   }) {
//     if (data.isEmpty) {
//       return Text(
//         "No items yet",
//         style: GoogleFonts.poppins(fontSize: 12, color: Colors.blueGrey[400]),
//       );
//     }

//     return Wrap(
//       spacing: 8,
//       runSpacing: 8,
//       children: data
//           .map(
//             (e) => Chip(
//               label: Text(e, style: GoogleFonts.poppins(fontSize: 12)),
//               backgroundColor: const Color(0xFFE3F3FE),
//               deleteIcon: const Icon(Icons.close, size: 18),
//               onDeleted: () => onDelete(e),
//             ),
//           )
//           .toList(),
//     );
//   }

//   // ---------------- BUILD ----------------

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Text(
//           "Create Locations",
//           style: GoogleFonts.poppins(
//             color: const Color(0xFF014576),
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         iconTheme: const IconThemeData(color: Color(0xFF014576)),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             // COUNTRY
//             _section(
//               title: "Countries",
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _createInput(
//                     controller: _country,
//                     onAdd: addCountry,
//                     loading: loadingCountry,
//                     hint: "Enter country name (e.g. India)",
//                   ),
//                   const SizedBox(height: 10),

//                   // Country chips
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: countries
//                         .map(
//                           (c) => Chip(
//                             label: Text(c.name),
//                           ),
//                         )
//                         .toList(),
//                   ),
//                 ],
//               ),
//             ),

//             // ZONE
//             _section(
//               title: "Zones",
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   DropdownButtonFormField<AdminCountry>(
//                     value: selectedCountry,
//                     items: countries
//                         .map((c) => DropdownMenuItem(
//                               value: c,
//                               child: Text(c.name),
//                             ))
//                         .toList(),
//                     onChanged: (v) {
//                       setState(() {
//                         selectedCountry = v;
//                       });

//                       _loadZonesForCountry();
//                     },
//                     decoration: InputDecoration(
//                       labelText: "Select country",
//                       filled: true,
//                       fillColor: Colors.white,
//                       border: const OutlineInputBorder(),
//                     ),
//                   ),
//                   const SizedBox(height: 10),

//                   _createInput(
//                     controller: _zone,
//                     onAdd: addZone,
//                     loading: loadingZone,
//                     hint: "Enter zone name (e.g. South)",
//                   ),
//                   const SizedBox(height: 10),

//                   // Zone chips
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: zones
//                         .map(
//                           (z) => Chip(
//                             label: Text(z.name),
//                           ),
//                         )
//                         .toList(),
//                   ),
//                 ],
//               ),
//             ),

//             // STATE
//             _section(
//               title: "States",
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   DropdownButtonFormField<AdminZone>(
//                     value: selectedZone,
//                     items: zones
//                         .map((z) => DropdownMenuItem(
//                               value: z,
//                               child: Text(z.name),
//                             ))
//                         .toList(),
//                     onChanged: (v) {
//                       setState(() {
//                         selectedZone = v;
//                       });

//                       _loadStatesForZone();
//                     },
//                     decoration: InputDecoration(
//                       labelText: "Select zone",
//                       filled: true,
//                       fillColor: Colors.white,
//                       border: const OutlineInputBorder(),
//                     ),
//                   ),
//                   const SizedBox(height: 10),

//                   _createInput(
//                     controller: _state,
//                     onAdd: addState,
//                     loading: loadingState,
//                     hint: "Enter state name (e.g. Gujarat)",
//                   ),
//                   const SizedBox(height: 10),

//                   // State chips
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: states
//                         .map(
//                           (s) => Chip(
//                             label: Text(s.name),
//                           ),
//                         )
//                         .toList(),
//                   ),
//                 ],
//               ),
//             ),

//             // CITY
//             _section(
//               title: "Cities",
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   DropdownButtonFormField<AdminState>(
//                     value: selectedState,
//                     items: states
//                         .map((s) => DropdownMenuItem(
//                               value: s,
//                               child: Text(s.name),
//                             ))
//                         .toList(),
//                     onChanged: (v) {
//                       setState(() {
//                         selectedState = v;
//                       });

//                       _loadCitiesForState();
//                     },
//                     decoration: InputDecoration(
//                       labelText: "Select state",
//                       filled: true,
//                       fillColor: Colors.white,
//                       border: const OutlineInputBorder(),
//                     ),
//                   ),
//                   const SizedBox(height: 10),

//                   _createInput(
//                     controller: _city,
//                     onAdd: addCity,
//                     loading: loadingCity,
//                     hint: "Enter city name (e.g. Ahmedabad)",
//                   ),
//                   const SizedBox(height: 10),

//                   // City chips
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: cities
//                         .map(
//                           (c) => Chip(
//                             label: Text(c),
//                           ),
//                         )
//                         .toList(),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
