import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// ✅ SAME AS SIGNUP (IMPORTANT FIX)
import 'package:snow_app/Data/Models/location_option.dart';

// ✅ KEEP THESE
import 'package:snow_app/Data/Repositories/common_repository.dart';
import 'package:snow_app/Data/Models/business_category.dart';
import 'package:snow_app/Data/models/New%20Model/newloginmodel/IglooOption.dart';
import 'package:snow_app/Data/models/New%20Model/newloginmodel/base_signup_repository.dart';
import 'package:snow_app/Data/models/New%20Model/newloginmodel/signup_module.dart';

import 'package:snow_app/core/app_toast.dart';
import 'package:snow_app/core/result.dart';
import 'package:snow_app/core/validators.dart';

class SignupFormPage extends StatefulWidget {
  final String userType;

  const SignupFormPage({super.key, required this.userType});

  @override
  State<SignupFormPage> createState() => _SignupFormPageState();
}

class _SignupFormPageState extends State<SignupFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _module = SignupModule();
  final _repo = BaseSignupRepository();
  final _common = CommonRepository();

  File? _aadharFile;
  final ImagePicker _picker = ImagePicker();

  File? _photo;
  File? _aadhar;

  bool _loading = false;
  bool _loadingLookups = false;

  // 👉 LOCATION
  List<CountryOption> _countries = [];
  CountryOption? _selectedCountry;
  ZoneOption? _selectedZone;
  StateOption? _selectedState;
  CityOption? _selectedCity;
  List<BusinessCategory> _categories = [];

  BusinessCategory? _selectedCategory;
  // 👉 IGLOO
  List<IglooOption> iglooList = [];
  int? selectedIglooId;
  final _passwordController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _companyDescriptionController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  bool _obscurePassword = true;

  // ---------------- PICKERS ----------------
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

  Future<void> pickPhoto() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,

        // 🔥 SIZE CONTROL
        maxWidth: 1024,
        maxHeight: 1024,

        // 🔥 COMPRESSION (0–100)
        imageQuality: 70,
      );

      if (picked != null) {
        final file = File(picked.path);

        // 🔥 CHECK SIZE (OPTIONAL DEBUG)
        final sizeInKB = await file.length() / 1024;

        print("📷 PHOTO PATH: ${picked.path}");
        print("📦 PHOTO SIZE: ${sizeInKB.toStringAsFixed(2)} KB");

        setState(() {
          _photo = file;
        });

        context.showToast("Photo selected ✔");
      } else {
        print("❌ PHOTO NOT SELECTED");
      }
    } catch (e) {
      print("🔥 PHOTO ERROR: $e");
      context.showToast("Error picking photo", bg: Colors.red);
    }
  }

  // ---------------- LOAD LOCATION ----------------
  Future<void> loadLocations() async {
    setState(() => _loadingLookups = true);

    final res = await _common.fetchLocations();

    switch (res) {
      case Ok(value: final data):
        _countries = data;
        break;
      case Err(message: final msg, code: _):
        context.showToast(msg, bg: Colors.red);
        break;
    }

    setState(() => _loadingLookups = false);
  }

  @override
  void initState() {
    super.initState();
    loadLocations();
    loadCategories(); // ✅ ADD THIS
  }

  InputDecoration _fieldDecoration(String label) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  );
  // ---------------- FETCH IGLOO ----------------
  Future fetchIgloos(int cityId) async {
    print("📍 Fetching igloos for city: $cityId");

    final res = await _common.fetchIgloosByCity(cityId);

    switch (res) {
      case Ok(value: final list):
        setState(() {
          iglooList = list;

          // 🔥 RESET SELECTION
          selectedIglooId = null;
        });

        print("✅ IGLOOS: ${list.length}");
        break;

      case Err(message: final msg, code: _):
        context.showToast(msg ?? "Error fetching igloos", bg: Colors.red);
        break;
    }
  }

  Future<void> loadCategories() async {
    final res = await _common.fetchBusinessCategories();

    switch (res) {
      case Ok(value: final data):
        setState(() => _categories = data);
        break;

      case Err(message: final msg, code: _):
        context.showToast(msg, bg: Colors.red);
        break;
    }
  }

  // ---------------- SUBMIT ----------------
  Future submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_photo == null) {
      context.showToast("Please upload profile photo", bg: Colors.red);
      return;
    }

    if (_aadharFile == null) {
      context.showToast("Please upload Aadhaar", bg: Colors.red);
      return;
    }

    if (selectedIglooId == null) {
      context.showToast("Select Igloo", bg: Colors.red);
      return;
    }

    _module.iglooId = selectedIglooId.toString();
    _module.country = _selectedCountry!.id;
    _module.zone = _selectedZone!.id;
    _module.state = _selectedState!.id;
    _module.city = _selectedCity!.id;
    _module.fullName = _module.fullName;
    _module.email = _module.email;
    _module.password = _module.password;

    _module.businessName = _businessNameController.text.trim();
    _module.businessCategory = _selectedCategory!.name;
    _module.contact = _contactController.text.trim();
    _module.companyDescription = _companyDescriptionController.text.trim();
    _module.linkedin = _linkedinController.text.trim();
    _module.facebook = _facebookController.text.trim();
    _module.instagram = _instagramController.text.trim();

    setState(() => _loading = true);

    final res = await _repo.register(
      body: _module.toBody(widget.userType),
      aadhar: _aadharFile!,
      photo: _photo!,
    );

    setState(() => _loading = false);

    switch (res) {
      case Ok(value: final data):
        print("✅ SUCCESS ${data.message}");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data.message ?? "Registration successful"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // ⏳ Wait for snackbar then pop
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });

        break;
      case Err(message: final msg, code: _):
        context.showToast(msg ?? "Error", bg: Colors.red);
        break;
    }
  }

  InputDecoration deco(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // 🔥 important

      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset('assets/bglogin.jpg', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: _loadingLookups
                    ? const CircularProgressIndicator()
                    : SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Text(
                                "${widget.userType.replaceAll("_", " ").toUpperCase()} Registration",

                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5E9BC8),
                                ),
                              ),

                              const SizedBox(height: 16),

                              TextFormField(
                                decoration: deco("Full Name"),
                                onChanged: (v) => _module.fullName = v,
                                validator: (v) =>
                                    Validators.required(v, label: "Full Name"),
                              ),

                              const SizedBox(height: 16),

                              TextFormField(
                                decoration: deco("Email"),
                                onChanged: (v) => _module.email = v,
                                validator: Validators.email,
                              ),

                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Password *',
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12),
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),

                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                onChanged: (v) => _module.password = v,

                                validator: (v) =>
                                    Validators.minLen(v, 6, label: 'Password'),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _businessNameController,
                                decoration: _fieldDecoration('Business Name *'),
                                validator: (v) => Validators.required(
                                  v,
                                  label: 'Business Name',
                                ),
                              ),
                              const SizedBox(height: 16),
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
                                  if (_categories.isEmpty) {
                                    return 'Business categories unavailable';
                                  }
                                  if (value == null) {
                                    return 'Please select business category';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
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

                              // 🌍 COUNTRY
                              DropdownButtonFormField<CountryOption>(
                                value: _selectedCountry,
                                items: _countries
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  setState(() {
                                    _selectedCountry = v;
                                    _selectedZone = null;
                                    _selectedState = null;
                                    _selectedCity = null;
                                  });
                                },
                                decoration: deco("Country"),
                                validator: (v) =>
                                    v == null ? "Select country" : null,
                              ),

                              const SizedBox(height: 16),

                              // 🌍 ZONE
                              DropdownButtonFormField<ZoneOption>(
                                value: _selectedZone,
                                items:
                                    _selectedCountry?.zones
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(e.name),
                                          ),
                                        )
                                        .toList() ??
                                    [],
                                onChanged: (v) {
                                  setState(() {
                                    _selectedZone = v;
                                    _selectedState = null;
                                    _selectedCity = null;
                                  });
                                },
                                decoration: deco("Zone"),
                                validator: (v) =>
                                    v == null ? "Select zone" : null,
                              ),

                              const SizedBox(height: 16),

                              // 🌍 STATE
                              DropdownButtonFormField<StateOption>(
                                value: _selectedState,
                                items:
                                    _selectedZone?.states
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(e.name),
                                          ),
                                        )
                                        .toList() ??
                                    [],
                                onChanged: (v) {
                                  setState(() {
                                    _selectedState = v;
                                    _selectedCity = null;
                                  });
                                },
                                decoration: deco("State"),
                                validator: (v) =>
                                    v == null ? "Select state" : null,
                              ),

                              const SizedBox(height: 16),

                              // 🌍 CITY
                              DropdownButtonFormField<CityOption>(
                                value: _selectedCity,
                                items:
                                    _selectedState?.cities
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(e.name),
                                          ),
                                        )
                                        .toList() ??
                                    [],
                                onChanged: (v) {
                                  setState(() => _selectedCity = v);
                                  fetchIgloos(v!.id);
                                },
                                decoration: deco("City"),
                                validator: (v) =>
                                    v == null ? "Select city" : null,
                              ),

                              const SizedBox(height: 16),

                              // 🧊 IGLOO DROPDOWN
                              DropdownButtonFormField<int>(
                                value:
                                    iglooList.any(
                                      (e) => e.id == selectedIglooId,
                                    )
                                    ? selectedIglooId
                                    : null, // 🔥 CRITICAL FIX

                                decoration: deco("Select Igloo"),

                                items: iglooList.map((e) {
                                  return DropdownMenuItem(
                                    value: e.id,
                                    child: Text(e.name),
                                  );
                                }).toList(),

                                onChanged: (v) {
                                  setState(() {
                                    selectedIglooId = v;
                                  });
                                },

                                validator: (v) => iglooList.isEmpty
                                    ? null
                                    : (v == null ? "Select Igloo" : null),
                              ),

                              if (iglooList.isEmpty && _selectedCity != null)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    "No igloos available for this city",
                                  ),
                                ),

                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _companyDescriptionController,
                                decoration: _fieldDecoration(
                                  'Company Description *',
                                ),
                                maxLines: 3,
                                validator: (v) => Validators.required(
                                  v,
                                  label: 'Company Description',
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _linkedinController,
                                decoration: _fieldDecoration('LinkedIn URL'),
                                keyboardType: TextInputType.url,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _facebookController,
                                decoration: _fieldDecoration('Facebook URL'),
                                keyboardType: TextInputType.url,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _instagramController,
                                decoration: _fieldDecoration('Instagram URL'),
                                keyboardType: TextInputType.url,
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: pickPhoto,
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
                                        Icons.person,
                                        color: Color(0xFF5E9BC8),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _photo == null
                                              ? 'Upload Profile Photo (jpg/png, max 2MB)'
                                              : 'Photo selected ✔',
                                          style: TextStyle(
                                            color: _photo == null
                                                ? Colors.grey
                                                : Colors.green,
                                          ),
                                        ),
                                      ),
                                      if (_photo != null)
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

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

                              const SizedBox(height: 20),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5E9BC8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    minimumSize: const Size(
                                      double.infinity,
                                      50,
                                    ),
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Submit',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
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
