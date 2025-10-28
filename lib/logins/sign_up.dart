import 'package:flutter/material.dart';
import 'package:snow_app/Data/Models/business_category.dart';
import 'package:snow_app/Data/Repositories/New%20Repositories/locations_repo.dart';
import 'package:snow_app/Data/Repositories/New%20Repositories/new_categoryRepo.dart';
import 'package:snow_app/Data/Repositories/auth_repository.dart';
import 'package:snow_app/Data/Repositories/common_repository.dart';
import 'package:snow_app/Data/models/New%20Model/locations.dart';
import 'package:snow_app/Data/models/New%20Model/new_category.dart';
import 'package:snow_app/core/app_toast.dart';
import 'package:snow_app/core/result.dart';
import 'package:snow_app/core/validators.dart';

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
  final _cityController = TextEditingController();
  final _companyDescController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _fbController = TextEditingController();
  final _instaController = TextEditingController();
  final TextEditingController _newCategoryNameController =
      TextEditingController();
  final TextEditingController _deleteCategoryIdController =
      TextEditingController();
  final BusinessCategoryRepository _categoryRepo = BusinessCategoryRepository();

  String _categoryMessage = '';

  final _auth = AuthRepository();
  final _common = CommonRepository();
  final _locationRepo = LocationRepository(); // Use your LocationRepository

  BusinessCategory? _selectedCategory;
  List<BusinessCategory> _categories = [];
  bool _isLoading = false;

  List<LocationData> _locations = [];
  LocationData? _selectedCountry;
  ZoneData? _selectedZone;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadLocations(); // Fetch countries and zones
  }

  Future<void> _loadCategories() async {
    final res = await _common.fetchBusinessCategories();
    if (!mounted) return;

    if (res is Ok<List<BusinessCategory>>) {
      setState(() => _categories = res.value);
    } else if (res is Err) {
      context.showToast('Failed to load categories', bg: Colors.red);
    }
  }

  Future<void> _loadLocations() async {
    try {
      final data = await _locationRepo.fetchLocations();
      if (!mounted) return;
      setState(() => _locations = data.locations);
    } catch (e) {
      context.showToast('Failed to load locations', bg: Colors.red);
    }
  }

  Future<void> _addCategoryFromSignup() async {
    final name = _newCategoryNameController.text.trim();
    if (name.isEmpty) {
      setState(() => _categoryMessage = "Please enter category name");
      return;
    }

    try {
      final slug = name.toLowerCase().replaceAll(' ', '-');
      final model = NewCategoryModel(name: name, slug: slug);
      final result = await _categoryRepo.addCategory(model);

      setState(() => _categoryMessage = result);
      await _loadCategories(); // Refresh dropdown list
    } catch (e) {
      setState(() => _categoryMessage = e.toString());
    }
  }

  Future<void> _deleteCategoryFromSignup() async {
    final id = int.tryParse(_deleteCategoryIdController.text.trim());
    if (id == null) {
      setState(() => _categoryMessage = "Enter a valid ID");
      return;
    }

    try {
      final success = await _categoryRepo.deleteCategory(id);
      setState(
        () => _categoryMessage = success
            ? "Category deleted successfully!"
            : "Failed to delete category",
      );

      await _loadCategories(); // Refresh list
    } catch (e) {
      setState(() => _categoryMessage = e.toString());
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      context.showToast('Fix validation errors');
      return;
    }

    setState(() => _isLoading = true);

    final body = {
      'full_name': _fullNameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      if (_businessNameController.text.isNotEmpty)
        'business_name': _businessNameController.text.trim(),
      if (_selectedCategory != null) 'business_category': _selectedCategory!.id,
      if (_contactController.text.isNotEmpty)
        'contact': _contactController.text.trim(),
      if (_cityController.text.isNotEmpty) 'city': _cityController.text.trim(),
      if (_selectedCountry != null) 'country': _selectedCountry!.country,
      if (_selectedZone != null) 'zone': _selectedZone!.zone,
      if (_companyDescController.text.isNotEmpty)
        'company_description': _companyDescController.text.trim(),
      if (_linkedinController.text.isNotEmpty)
        'linkedin_id': _linkedinController.text.trim(),
      if (_fbController.text.isNotEmpty)
        'facebook_id': _fbController.text.trim(),
      if (_instaController.text.isNotEmpty)
        'instagram_id': _instaController.text.trim(),
    };

    final res = await _auth.signup(body);

    setState(() => _isLoading = false);

    switch (res) {
      case Ok(value: final v):
        context.showToast(v.message);
        Navigator.pop(context);
        break;
      case Err(message: final msg, code: final code):
        context.showToast('Signup failed ($code): $msg', bg: Colors.red);
    }
  }

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
                width: 350,
                child: SingleChildScrollView(
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
                          decoration: const InputDecoration(
                            hintText: 'Full Name *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                          validator: (v) =>
                              Validators.required(v, label: 'Full Name'),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            hintText: 'Email *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: 'Password *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                          validator: (v) =>
                              Validators.minLen(v, 6, label: 'Password'),
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
                          onChanged: (v) =>
                              setState(() => _selectedCategory = v),
                          decoration: const InputDecoration(
                            labelText: 'Business Category (optional)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _businessNameController,
                          decoration: const InputDecoration(
                            hintText: 'Business Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _contactController,
                          decoration: const InputDecoration(
                            hintText: 'Contact',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(
                            hintText: 'City',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _businessNameController,
                          decoration: const InputDecoration(
                            hintText: 'Business Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 🌿 Add Business Category (Styled Consistently)
                        TextFormField(
                          controller: _newCategoryNameController,
                          decoration: InputDecoration(
                            hintText: 'Add Business Category Name',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFBDBDBD),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: Container(
                              margin: const EdgeInsets.only(right: 2),
                              child: ElevatedButton.icon(
                                onPressed: _addCategoryFromSignup,
                                icon: const Icon(
                                  Icons.add_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Add',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 11,
                                  ),
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<LocationData>(
                          value: _selectedCountry,
                          items: _locations
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c.country),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() {
                            _selectedCountry = v;
                            _selectedZone = null;
                          }),
                          validator: (v) =>
                              v == null ? 'Please select a country' : null,
                          decoration: const InputDecoration(
                            labelText: 'Country *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // --- Zone Dropdown ---
                        DropdownButtonFormField<ZoneData>(
                          value: _selectedZone,
                          items:
                              _selectedCountry?.zones
                                  .map(
                                    (z) => DropdownMenuItem(
                                      value: z,
                                      child: Text(z.zone),
                                    ),
                                  )
                                  .toList() ??
                              [],
                          onChanged: (v) => setState(() => _selectedZone = v),
                          decoration: const InputDecoration(
                            labelText: 'Zone',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _companyDescController,
                          decoration: const InputDecoration(
                            hintText: 'Company Description',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        TextFormField(
                          controller: _linkedinController,
                          decoration: const InputDecoration(
                            hintText: 'LinkedIn ID',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        TextFormField(
                          controller: _fbController,
                          decoration: const InputDecoration(
                            hintText: 'Facebook ID',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        TextFormField(
                          controller: _instaController,
                          decoration: const InputDecoration(
                            hintText: 'Instagram ID',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: _isLoading ? null : _signUp,
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
