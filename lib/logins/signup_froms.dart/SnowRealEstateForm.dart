import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:snow_app/Data/Models/business_category.dart';
import 'package:snow_app/Data/Models/location_option.dart';
import 'package:snow_app/Data/Repositories/SnowRealEstateRepository.dart';
import 'package:snow_app/Data/Repositories/common_repository.dart';
import 'package:snow_app/core/app_toast.dart';
import 'package:snow_app/core/result.dart';
import 'package:snow_app/core/validators.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class SnowRealEstateFormPage extends StatefulWidget {
  const SnowRealEstateFormPage({super.key});

  @override
  State<SnowRealEstateFormPage> createState() => _SnowRealEstateFormPageState();
}

class _SnowRealEstateFormPageState extends State<SnowRealEstateFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessCategoryTextController =
      TextEditingController(); // kept if needed
  final _citiesController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _cityTextController = TextEditingController();
  final _passwordController = TextEditingController();

  final SnowRealEstateRepository _repository = SnowRealEstateRepository();
  final CommonRepository _common = CommonRepository();

  bool _isLoading = false;
  bool _isLoadingLookups = false;

  List<BusinessCategory> _categories = [];
  List<CountryOption> _countries = [];

  BusinessCategory? _selectedCategory;
  CountryOption? _selectedCountry;
  ZoneOption? _selectedZone;
  StateOption? _selectedState;
  CityOption? _selectedCity;
  File? _aadharFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadLookups();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _businessCategoryTextController.dispose();
    _citiesController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _cityTextController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickAadhar() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // compress
    );

    if (picked == null) return;

    final file = File(picked.path);
    final size = await file.length();

    const maxSize = 2 * 1024 * 1024; // 2 MB

    if (size > maxSize) {
      context.showToast('Aadhaar image must be under 2MB', bg: Colors.red);
      return;
    }

    setState(() => _aadharFile = file);
  }

  Future<void> _loadLookups() async {
    setState(() => _isLoadingLookups = true);

    final categoryResult = await _common.fetchBusinessCategories();
    final locationResult = await _common.fetchLocations();

    List<BusinessCategory> categories = [];
    List<CountryOption> countries = [];

    switch (categoryResult) {
      case Ok(value: final value):
        categories = value;
        break;
      case Err(message: final msg, code: _):
        if (mounted) context.showToast(msg, bg: Colors.red);
        break;
    }

    switch (locationResult) {
      case Ok(value: final value):
        countries = value;
        break;
      case Err(message: final msg, code: _):
        if (mounted) context.showToast(msg, bg: Colors.red);
        break;
    }

    if (!mounted) return;
    setState(() {
      _categories = categories;
      _countries = countries;
      _isLoadingLookups = false;
    });
  }

  Future<void> _submit() async {
    if (_aadharFile == null) {
      context.showToast('Please upload Aadhaar card', bg: Colors.red);
      return;
    }

    if (!_formKey.currentState!.validate()) {
      if (mounted) context.showToast('Fix validation errors', bg: Colors.red);
      return;
    }

    if (_selectedCategory == null) {
      if (mounted)
        context.showToast('Please select a business category', bg: Colors.red);
      return;
    }

    if (_selectedCountry == null ||
        _selectedZone == null ||
        _selectedState == null ||
        _selectedCity == null) {
      if (mounted)
        context.showToast(
          'Please complete your location details',
          bg: Colors.red,
        );
      return;
    }

    setState(() => _isLoading = true);

    final fullName = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final businessName = _businessNameController.text.trim();
    final contact = _contactController.text.trim();
    final website = _websiteController.text.trim();

    final int countryId = _selectedCountry!.id;
    final int zoneId = _selectedZone!.id;
    final int stateId = _selectedState!.id;
    final int cityId = _selectedCity!.id;

    try {
      final resp = await _repository.registerRealEstate(
        fullName: fullName,
        email: email,
        password: password,
        businessName: businessName,
        businessCategory: _selectedCategory!.id.toString(), // <--- fix
        country: countryId,
        zone: zoneId,
        state: stateId,
        city: cityId,
        contact: contact,
        website: website.isEmpty ? null : website,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (resp != null) {
        final success = resp.success;
        final message = resp.message.isNotEmpty
            ? resp.message
            : (success ? 'Submitted' : 'Failed');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );

        if (success) {
          _formKey.currentState!.reset();
          setState(() {
            _selectedCategory = null;
            _selectedCountry = null;
            _selectedZone = null;
            _selectedState = null;
            _selectedCity = null;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unexpected response from server')),
        );
      }
    } catch (e, st) {
      if (kDebugMode) {
        print('Register error: $e\n$st');
      }
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}')),
      );
    }
  }

  InputDecoration _fieldDecoration(String label) =>
      InputDecoration(hintText: label, border: const OutlineInputBorder());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset('assets/bglogin.jpg', fit: BoxFit.cover),
          ),
          Container(color: Colors.black.withOpacity(0.4)),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: _isLoadingLookups
                    ? const SizedBox(
                        height: 260,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'SnowRealEstate Registration',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5E9BC8),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Full Name
                              TextFormField(
                                controller: _nameController,
                                decoration: _fieldDecoration('Full Name *'),
                                validator: (v) =>
                                    Validators.required(v, label: 'Full Name'),
                              ),
                              const SizedBox(height: 16),

                              // Business Name
                              TextFormField(
                                controller: _businessNameController,
                                decoration: _fieldDecoration('Business Name *'),
                                validator: (v) => Validators.required(
                                  v,
                                  label: 'Business Name',
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Business Category - dropdown (mirrors SignUpPage)
                              DropdownButtonFormField<BusinessCategory>(
                                  isExpanded: true, 

                                value: _selectedCategory,
                                items: _categories
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(c.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) =>
                                    setState(() => _selectedCategory = value),
                                decoration: _fieldDecoration(
                                  'Business Category *',
                                ),
                                validator: (value) {
                                  if (_categories.isEmpty)
                                    return 'Business categories unavailable';
                                  if (value == null)
                                    return 'Please select business category';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Cities you operate in (free text)
                              TextFormField(
                                controller: _citiesController,
                                decoration: _fieldDecoration(
                                  'Cities you operate in *',
                                ),
                                validator: (v) =>
                                    Validators.required(v, label: 'Cities'),
                              ),
                              const SizedBox(height: 16),

                              // Contact Number
                              TextFormField(
                                controller: _contactController,
                                decoration: _fieldDecoration(
                                  'Contact Number *',
                                ),
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Contact Number is required';
                                  }

                                  final value = v.trim();

                                  if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                                    return 'Contact Number must be exactly 10 digits';
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Email
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: _fieldDecoration('Email Id *'),
                                validator: Validators.email,
                              ),
                              const SizedBox(height: 16),

                              // Password (required by repo)
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: _fieldDecoration('Password *'),
                                validator: (v) =>
                                    Validators.minLen(v, 6, label: 'Password'),
                              ),
                              const SizedBox(height: 16),

                              // Website (optional)
                              TextFormField(
                                controller: _websiteController,
                                decoration: _fieldDecoration(
                                  'Website (if any)',
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Location dropdowns (Country → Zone → State → City)
                              _LocationDropdown<CountryOption>(
                                items: _countries,
                                label: 'Country *',
                                value: _selectedCountry,
                                display: (c) => c.name,
                                onChanged: (country) {
                                  setState(() {
                                    _selectedCountry = country;
                                    _selectedZone = null;
                                    _selectedState = null;
                                    _selectedCity = null;
                                  });
                                },
                                validator: (value) {
                                  if (_countries.isEmpty)
                                    return 'Locations unavailable';
                                  if (value == null) return 'Select country';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _LocationDropdown<ZoneOption>(
                                items:
                                    _selectedCountry?.zones ??
                                    const <ZoneOption>[],
                                label: 'Zone *',
                                value: _selectedZone,
                                display: (z) => z.name,
                                enabled: _selectedCountry != null,
                                onChanged: (zone) {
                                  setState(() {
                                    _selectedZone = zone;
                                    _selectedState = null;
                                    _selectedCity = null;
                                  });
                                },
                                validator: (value) {
                                  if ((_selectedCountry?.zones ?? []).isEmpty)
                                    return 'Zones unavailable';
                                  if (value == null) return 'Select zone';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _LocationDropdown<StateOption>(
                                items:
                                    _selectedZone?.states ??
                                    const <StateOption>[],
                                label: 'State *',
                                value: _selectedState,
                                display: (s) => s.name,
                                enabled: _selectedZone != null,
                                onChanged: (state) {
                                  setState(() {
                                    _selectedState = state;
                                    _selectedCity = null;
                                  });
                                },
                                validator: (value) {
                                  if ((_selectedZone?.states ?? []).isEmpty)
                                    return 'States unavailable';
                                  if (value == null) return 'Select state';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _LocationDropdown<CityOption>(
                                items:
                                    _selectedState?.cities ??
                                    const <CityOption>[],
                                label: 'City *',
                                value: _selectedCity,
                                display: (c) => c.name,
                                enabled: _selectedState != null,
                                onChanged: (city) =>
                                    setState(() => _selectedCity = city),
                                validator: (value) {
                                  if ((_selectedState?.cities ?? []).isEmpty)
                                    return 'Cities unavailable';
                                  if (value == null) return 'Select city';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Aadhaar Card *',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              InkWell(
                                onTap: _pickAadhar,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey.shade50,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.upload_file,
                                        color: Color(0xFF5E9BC8),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _aadharFile == null
                                              ? 'Upload Aadhaar image (jpg/png, max 2MB)'
                                              : 'Aadhaar selected ✔',
                                          style: TextStyle(
                                            color: _aadharFile == null
                                                ? Colors.grey
                                                : Colors.green,
                                          ),
                                        ),
                                      ),
                                      if (_aadharFile != null)
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Submit Button
                              ElevatedButton(
                                onPressed: _isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5E9BC8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        'Submit',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: _isLoadingLookups
                                    ? null
                                    : _loadLookups,
                                child: const Text(
                                  'Refresh dropdowns',
                                  style: TextStyle(color: Color(0xFF5E9BC8)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Generic location dropdown (same pattern used in SignUpPage)
class _LocationDropdown<T> extends StatelessWidget {
  final List<T> items;
  final String label;
  final T? value;
  final String Function(T value) display;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;
  final bool enabled;

  const _LocationDropdown({
    required this.items,
    required this.label,
    required this.value,
    required this.display,
    required this.onChanged,
    required this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: enabled ? value : null,
      items: items
          .map(
            (item) =>
                DropdownMenuItem<T>(value: item, child: Text(display(item))),
          )
          .toList(),
      onChanged: enabled ? onChanged : null,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
