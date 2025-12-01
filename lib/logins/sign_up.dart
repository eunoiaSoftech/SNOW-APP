import 'package:flutter/material.dart';
import 'package:snow_app/Data/Models/business_category.dart';
import 'package:snow_app/Data/Models/location_option.dart';
import 'package:snow_app/Data/Repositories/auth_repository.dart';
import 'package:snow_app/Data/Repositories/common_repository.dart';
import 'package:snow_app/core/app_toast.dart';
import 'package:snow_app/core/result.dart';
import 'package:snow_app/core/validators.dart';
import 'package:snow_app/logins/login.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _companyDescriptionController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();

  final AuthRepository _auth = AuthRepository();
  final CommonRepository _common = CommonRepository();

  List<BusinessCategory> _categories = [];
  List<CountryOption> _countries = [];

  BusinessCategory? _selectedCategory;
  CountryOption? _selectedCountry;
  ZoneOption? _selectedZone;
  StateOption? _selectedState;
  CityOption? _selectedCity;

  bool _isSubmitting = false;
  bool _isLoadingLookups = false;

  @override
  void initState() {
    super.initState();
    _loadLookups();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _businessNameController.dispose();
    _contactController.dispose();
    _companyDescriptionController.dispose();
    _linkedinController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  Future<void> _loadLookups() async {
    setState(() => _isLoadingLookups = true);

    final categoryResult = await _common.fetchBusinessCategories();
    final locationResult = await _common.fetchLocations();

    if (!mounted) return;

    var categories = _categories;
    var countries = _countries;

    switch (categoryResult) {
      case Ok(value: final value):
        categories = value;
        break;
      case Err(message: final msg, code: _):
        context.showToast(msg, bg: Colors.red);
        break;
    }

    switch (locationResult) {
      case Ok(value: final value):
        countries = value;
        break;
      case Err(message: final msg, code: _):
        context.showToast(msg, bg: Colors.red);
        break;
    }

    setState(() {
      _categories = categories;
      _countries = countries;
      _isLoadingLookups = false;
    });
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      context.showToast('Fix validation errors');
      return;
    }

    if (_selectedCategory == null) {
      context.showToast('Please select a business category');
      return;
    }
    if (_selectedCountry == null ||
        _selectedZone == null ||
        _selectedState == null ||
        _selectedCity == null) {
      context.showToast('Please complete your location details');
      return;
    }

    setState(() => _isSubmitting = true);

    final body = {
      'user_type': 'elite',
      'full_name': _fullNameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'business_name': _businessNameController.text.trim(),
      'business_category': _selectedCategory!.id,
      'contact': _contactController.text.trim(),
      'country': _selectedCountry!.id,
      'zone': _selectedZone!.id,
      'state': _selectedState!.id,
      'city': _selectedCity!.id,
      'company_description': _companyDescriptionController.text.trim(),
      if (_linkedinController.text.trim().isNotEmpty)
        'linkedin_id': _linkedinController.text.trim(),
      if (_facebookController.text.trim().isNotEmpty)
        'facebook_id': _facebookController.text.trim(),
      if (_instagramController.text.trim().isNotEmpty)
        'instagram_id': _instagramController.text.trim(),
    };

    final res = await _auth.signup(body);

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    switch (res) {
      case Ok(value: final response):
        final message = response.message.isNotEmpty
            ? response.message
            : 'Registration submitted for approval';
        context.showToast(message);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
        break;
      case Err(message: final msg, code: final code):

        // Clean backend noise (like 401, 500, etc.)
        final cleanMsg = msg
            .replaceAll(RegExp(r"\b\d{3}\b"), "") // remove status codes
            .replaceAll("Exception:", "")
            .replaceAll("Error:", "")
            .trim();

        String userMsg;

        // Custom readable messages based on code
        if (code == 401) {
          userMsg =
              "Unauthorized request. Please try again.";
        } else if (code == 500) {
          userMsg =
              "Server is facing an issue right now. Please try again later.";
        } else if (code == 422) {
          userMsg =
              "Some required details look incorrect. Please review and try again.";
        } else {
          // fallback: use backend message IF clean
          userMsg = cleanMsg.isNotEmpty
              ? cleanMsg
              : "Something went wrong. Please try again.";
        }

        context.showToast(userMsg, bg: Colors.red);
        break;
    }
  }

  InputDecoration _fieldDecoration(String label) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset('assets/bglogin.jpg', fit: BoxFit.cover),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 55,
                left: 25,
                right: 25,
                bottom: 45,
              ),
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
                width: 380,
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
                                'Elite Registration',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5E9BC8),
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _fullNameController,
                                decoration: _fieldDecoration('Full Name *'),
                                validator: (v) =>
                                    Validators.required(v, label: 'Full Name'),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                decoration: _fieldDecoration('Email *'),
                                validator: Validators.email,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: _fieldDecoration('Password *'),
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
                                validator: (v) =>
                                    Validators.required(v, label: 'Contact'),
                              ),
                              const SizedBox(height: 16),
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
                                  if (_countries.isEmpty) {
                                    return 'Locations unavailable';
                                  }
                                  if (value == null) {
                                    return 'Select country';
                                  }
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
                                  if ((_selectedCountry?.zones ?? []).isEmpty) {
                                    return 'Zones unavailable';
                                  }
                                  if (value == null) {
                                    return 'Select zone';
                                  }
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
                                  if ((_selectedZone?.states ?? []).isEmpty) {
                                    return 'States unavailable';
                                  }
                                  if (value == null) {
                                    return 'Select state';
                                  }
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
                                  if ((_selectedState?.cities ?? []).isEmpty) {
                                    return 'Cities unavailable';
                                  }
                                  if (value == null) {
                                    return 'Select city';
                                  }
                                  return null;
                                },
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
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isSubmitting ? null : _signUp,
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
                                  child: _isSubmitting
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
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: _isLoadingLookups
                                    ? null
                                    : _loadLookups,
                                child: const Text('Refresh dropdowns', style: TextStyle(color: Color(0xFF5E9BC8))),
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
