import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/Data/Repositories/New%20Repositories/location_repo.dart';
import 'package:snow_app/Data/models/New%20Model/location_data123.dart'
    as location_models;
import 'package:snow_app/core/result.dart';

class FilterData {
  final String? businessName;
  final String? country;
  final String? countryId;
  final String? zone;
  final String? zoneId;
  final String? city;
  final String? cityId;

  FilterData({
    this.businessName,
    this.country,
    this.zone,
    this.city,
    this.cityId,
    this.countryId,
    this.zoneId,
  });

  bool get hasAnyFilter {
    return businessName?.isNotEmpty == true ||
        country?.isNotEmpty == true ||
        countryId?.isNotEmpty == true ||
        zone?.isNotEmpty == true ||
        zoneId?.isNotEmpty == true ||
        city?.isNotEmpty == true ||
        cityId?.isNotEmpty == true;
  }

  Map<String, String> toQueryParams() {
    final params = <String, String>{};

    if (businessName?.isNotEmpty == true) {
      params['search'] = businessName!;
    }
    if (countryId?.isNotEmpty == true && countryId != 'All') {
      params['country'] = countryId!;
    }
    if (zoneId?.isNotEmpty == true && zoneId != 'All') {
      params['zone'] = zoneId!;
    }
    if (cityId?.isNotEmpty == true && cityId != 'All') {
      params['city'] = cityId!;
    }

    return params;
  }
}

class EnhancedSearchIgloosDialog extends StatefulWidget {
  final FilterData? initialFilters;
  final Function(FilterData) onFiltersApplied;

  const EnhancedSearchIgloosDialog({
    Key? key,
    this.initialFilters,
    required this.onFiltersApplied,
  }) : super(key: key);

  @override
  _EnhancedSearchIgloosDialogState createState() =>
      _EnhancedSearchIgloosDialogState();
}

class _EnhancedSearchIgloosDialogState
    extends State<EnhancedSearchIgloosDialog> {
  final _businessNameController = TextEditingController();
  final _locationRepo = LocationRepository();

  String? _selectedCountry;
  String? _selectedZone;
  String? _selectedCity;

  List<String> _countries = ['All'];
  List<String> _zones = ['All'];
  List<String> _cities = ['All'];

  bool _isLoading = true;
  location_models.LocationData? _locationData;
  FilterData? _pendingInitialFilters;

  String? _getCountryIdByName(String? countryName) {
    if (countryName == null ||
        countryName.isEmpty ||
        countryName == 'All' ||
        _locationData == null) {
      return null;
    }
    final match = _locationData!.countries.where((c) => c.name == countryName);
    if (match.isEmpty) return null;
    return match.first.id.toString();
  }

  String? _getZoneIdByName(String? countryName, String? zoneName) {
    if (countryName == null ||
        zoneName == null ||
        countryName.isEmpty ||
        zoneName.isEmpty ||
        countryName == 'All' ||
        zoneName == 'All' ||
        _locationData == null) {
      return null;
    }
    final countryMatches =
        _locationData!.countries.where((c) => c.name == countryName);
    if (countryMatches.isEmpty) return null;
    final country = countryMatches.first;
    final zoneMatches = country.zones.where((z) => z.name == zoneName);
    if (zoneMatches.isEmpty) return null;
    return zoneMatches.first.id.toString();
  }

  String? _getCityIdByName(
    String? countryName,
    String? zoneName,
    String? cityName,
  ) {
    if (countryName == null ||
        zoneName == null ||
        cityName == null ||
        countryName.isEmpty ||
        zoneName.isEmpty ||
        cityName.isEmpty ||
        countryName == 'All' ||
        zoneName == 'All' ||
        cityName == 'All' ||
        _locationData == null) {
      return null;
    }
    final countryMatches =
        _locationData!.countries.where((c) => c.name == countryName);
    if (countryMatches.isEmpty) return null;
    final country = countryMatches.first;
    final zoneMatches = country.zones.where((z) => z.name == zoneName);
    if (zoneMatches.isEmpty) return null;
    final zone = zoneMatches.first;
    for (final st in zone.states) {
      final cityMatches = st.cities.where((c) => c.name == cityName);
      if (cityMatches.isNotEmpty) {
        return cityMatches.first.id.toString();
      }
    }
    return null;
  }

  String? _getCountryNameById(String? countryId) {
    if (countryId == null ||
        countryId.isEmpty ||
        countryId == 'All' ||
        _locationData == null) {
      return null;
    }
    final idInt = int.tryParse(countryId);
    if (idInt == null) return null;
    final matches = _locationData!.countries.where((c) => c.id == idInt);
    if (matches.isEmpty) return null;
    return matches.first.name;
  }

  String? _getZoneNameById(String? countryName, String? zoneId) {
    if (countryName == null ||
        zoneId == null ||
        countryName.isEmpty ||
        zoneId.isEmpty ||
        countryName == 'All' ||
        zoneId == 'All' ||
        _locationData == null) {
      return null;
    }
    final idInt = int.tryParse(zoneId);
    if (idInt == null) return null;
    final countryMatches =
        _locationData!.countries.where((c) => c.name == countryName);
    if (countryMatches.isEmpty) return null;
    final zones = countryMatches.first.zones;
    final matches = zones.where((z) => z.id == idInt);
    if (matches.isEmpty) return null;
    return matches.first.name;
  }

  String? _getCityNameById(
    String? countryName,
    String? zoneName,
    String? cityId,
  ) {
    if (countryName == null ||
        zoneName == null ||
        cityId == null ||
        countryName.isEmpty ||
        zoneName.isEmpty ||
        cityId.isEmpty ||
        countryName == 'All' ||
        zoneName == 'All' ||
        cityId == 'All' ||
        _locationData == null) {
      return null;
    }
    final idInt = int.tryParse(cityId);
    if (idInt == null) return null;

    final countryMatches =
        _locationData!.countries.where((c) => c.name == countryName);
    if (countryMatches.isEmpty) return null;
    final country = countryMatches.first;
    final zoneMatches = country.zones.where((z) => z.name == zoneName);
    if (zoneMatches.isEmpty) return null;
    final zone = zoneMatches.first;

    for (final st in zone.states) {
      final matches = st.cities.where((c) => c.id == idInt);
      if (matches.isNotEmpty) return matches.first.name;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _initializeFilters();
    _fetchLocationData();
  }

  void _initializeFilters() {
    // Always start with default values
    _selectedCountry = 'All';
    _selectedZone = 'All';
    _selectedCity = 'All';
    _businessNameController.clear();

    // Store initial filters to apply after location data is loaded
    _pendingInitialFilters = widget.initialFilters;
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocationData() async {
    setState(() => _isLoading = true);

    try {
      final result = await _locationRepo.fetchLocationData();

      if (result is Ok<location_models.LocationData>) {
        setState(() {
          _locationData = result.value;
          _countries = ['All', ..._locationRepo.getCountries(result.value)];
          _isLoading = false;
        });

        // Apply pending initial filters after location data is loaded
        _applyPendingInitialFilters();
      } else if (result is Err<location_models.LocationData>) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to load location data: ${result.message}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading location data: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _applyPendingInitialFilters() {
    if (_pendingInitialFilters == null || _locationData == null) return;

    final filters = _pendingInitialFilters!;

    setState(() {
      // Set business name
      _businessNameController.text = filters.businessName ?? '';

      final resolvedCountryName =
          _getCountryNameById(filters.countryId) ?? filters.country;

      // Validate and set country (by id preferred, name fallback)
      if (resolvedCountryName != null && resolvedCountryName != 'All') {
        if (_countries.contains(resolvedCountryName)) {
          _selectedCountry = resolvedCountryName;
          _zones = [
            'All',
            ..._locationRepo.getZonesForCountry(
              _locationData!,
              resolvedCountryName,
            ),
          ];

          final resolvedZoneName = _getZoneNameById(
                resolvedCountryName,
                filters.zoneId,
              ) ??
              filters.zone;

          // Validate and set zone (by id preferred, name fallback)
          if (resolvedZoneName != null && resolvedZoneName != 'All') {
            if (_zones.contains(resolvedZoneName)) {
              _selectedZone = resolvedZoneName;
              _cities = [
                'All',
                ..._locationRepo.getCitiesForCountryAndZone(
                  _locationData!,
                  resolvedCountryName,
                  resolvedZoneName,
                ),
              ];

              final resolvedCityName = _getCityNameById(
                    resolvedCountryName,
                    resolvedZoneName,
                    filters.cityId,
                  ) ??
                  filters.city;

              // Validate and set city (by id preferred, name fallback)
              if (resolvedCityName != null && resolvedCityName != 'All') {
                if (_cities.contains(resolvedCityName)) {
                  _selectedCity = resolvedCityName;
                } else {
                  _selectedCity = 'All';
                }
              } else {
                _selectedCity = 'All';
              }
            } else {
              _selectedZone = 'All';
              _cities = ['All'];
            }
          } else {
            _selectedZone = 'All';
            _cities = ['All'];
          }
        } else {
          _selectedCountry = 'All';
          _zones = ['All'];
          _cities = ['All'];
        }
      } else {
        _selectedCountry = 'All';
        _zones = ['All'];
        _cities = ['All'];
      }
    });

    // Clear pending filters
    _pendingInitialFilters = null;
  }

  void _onCountryChanged(String? country) {
    setState(() {
      _selectedCountry = country;
      _selectedZone = 'All';
      _selectedCity = 'All';

      if (country != null && country != 'All' && _locationData != null) {
        _zones = [
          'All',
          ..._locationRepo.getZonesForCountry(_locationData!, country),
        ];
        _cities = ['All'];
      } else {
        _zones = ['All'];
        _cities = ['All'];
      }
    });
  }

  void _onZoneChanged(String? zone) {
    setState(() {
      _selectedZone = zone;
      _selectedCity = 'All';

      if (zone != null &&
          zone != 'All' &&
          _selectedCountry != null &&
          _selectedCountry != 'All' &&
          _locationData != null) {
        _cities = [
          'All',
          ..._locationRepo.getCitiesForCountryAndZone(
            _locationData!,
            _selectedCountry!,
            zone,
          ),
        ];
      } else {
        _cities = ['All'];
      }
    });
  }

  void _onCityChanged(String? city) {
    setState(() {
      _selectedCity = city;
    });
  }

  void _resetSearch() {
    setState(() {
      _businessNameController.clear();
      _selectedCountry = 'All';
      _selectedZone = 'All';
      _selectedCity = 'All';
      _zones = ['All'];
      _cities = ['All'];
    });
  }

  void _applyFilters() {
    final selectedCountryName = _selectedCountry == 'All' ? null : _selectedCountry;
    final selectedZoneName = _selectedZone == 'All' ? null : _selectedZone;
    final selectedCityName = _selectedCity == 'All' ? null : _selectedCity;

    final resolvedCountryId = _getCountryIdByName(selectedCountryName);
    final resolvedZoneId = _getZoneIdByName(selectedCountryName, selectedZoneName);
    final resolvedCityId =
        _getCityIdByName(selectedCountryName, selectedZoneName, selectedCityName);

    final filterData = FilterData(
      businessName: _businessNameController.text.trim().isEmpty
          ? null
          : _businessNameController.text.trim(),
      country: selectedCountryName,
      countryId: resolvedCountryId,
      zone: selectedZoneName,
      zoneId: resolvedZoneId,
      city: selectedCityName,
      cityId: resolvedCityId,
    );

    widget.onFiltersApplied(filterData);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFFEAF5FC), Color(0xFFD8E7FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(28, 22, 28, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      "Filter Cross IGLOO Members",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF014576),
                      ),
                    ),
                  ),
                  Material(
                    color: const Color.fromARGB(
                      255,
                      154,
                      192,
                      240,
                    ).withOpacity(0.1),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Description
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Select filters to narrow down your search results.",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.blueGrey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Loading indicator
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF014576)),
                  ),
                ),
              // Business Name Field
              _buildDialogTextField('Business Name', _businessNameController),
              const SizedBox(height: 16),

              // Show applied filters as chips (only when any filter is active)
              if (widget.initialFilters != null &&
                  widget.initialFilters!.hasAnyFilter)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFB6C6E2),
                      width: 1,
                    ),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (widget.initialFilters!.businessName != null)
                        _buildChip(
                          "Name: ${widget.initialFilters!.businessName!}",
                        ),
                      if (widget.initialFilters!.country != null)
                        _buildChip(
                          "Country: ${widget.initialFilters!.country!}",
                        ),
                      if (widget.initialFilters!.zone != null)
                        _buildChip("Zone: ${widget.initialFilters!.zone!}"),
                      if (widget.initialFilters!.city != null)
                        _buildChip("City: ${widget.initialFilters!.city!}"),
                    ],
                  ),
                ),

              const SizedBox(height: 16),
              // Dropdowns 1
              Row(
                children: [
                  Expanded(
                    child: _buildDialogDropdown(
                      'Country',
                      _countries,
                      _selectedCountry,
                      _onCountryChanged,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDialogDropdown(
                      'Zone',
                      _zones,
                      _selectedZone,
                      _onZoneChanged,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Dropdowns 2
              Row(
                children: [
                  Expanded(
                    child: _buildDialogDropdown(
                      'City',
                      _cities,
                      _selectedCity,
                      _onCityChanged,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF014576),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'APPLY FILTERS',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _resetSearch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'RESET',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.black87,
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
    );
  }

  Widget _buildDialogTextField(String hint, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.blueGrey[400],
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF014576), width: 1.5),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      style: GoogleFonts.poppins(fontSize: 15),
    );
  }

  Widget _buildChip(String text) {
    return Chip(
      label: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: const Color(0xFF014576),
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: const Color(0xFFDDEBFA),
      side: const BorderSide(color: Color(0xFF9BB5D8)),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
    );
  }

  Widget _buildDialogDropdown(
    String hint,
    List<String> items,
    String? selectedValue,
    Function(String?) onChanged,
  ) {
    // Validate that selectedValue exists in items, if not set to null
    final validSelectedValue =
        (selectedValue != null && items.contains(selectedValue))
        ? selectedValue
        : null;

    return DropdownButtonFormField<String>(
      value: validSelectedValue,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.blueGrey[400],
        ),
        filled: true,
        fillColor: _isLoading ? Colors.grey.shade300 : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF014576), width: 1.5),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: GoogleFonts.poppins(fontSize: 13)),
        );
      }).toList(),
      onChanged: _isLoading ? null : onChanged,
    );
  }
}
