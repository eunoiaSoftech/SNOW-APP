import 'package:flutter/material.dart';
import 'package:snow_app/Data/Models/business_category.dart';
import 'package:snow_app/Data/Repositories/auth_repository.dart';
import 'package:snow_app/Data/Repositories/common_repository.dart';
import 'package:snow_app/core/app_toast.dart';
import 'package:snow_app/core/result.dart';
import 'package:snow_app/core/validators.dart';
import 'package:snow_app/logins/login.dart';

class VisitorFormPage extends StatefulWidget {
  const VisitorFormPage({super.key});

  @override
  State<VisitorFormPage> createState() => _VisitorFormPageState();
}

class _VisitorFormPageState extends State<VisitorFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _yearsInBusinessController = TextEditingController();
  final _gstController = TextEditingController();
  final _websiteController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _contactController = TextEditingController();

  final AuthRepository _auth = AuthRepository();
  final CommonRepository _common = CommonRepository();

  List<BusinessCategory> _categories = [];
  BusinessCategory? _selectedCategory;
  String? _selectedBusinessType;
  String? _selectedJoinPreference;
  bool _paymentDone = false;

  bool _isLoadingCategories = false;
  bool _isSubmitting = false;

  static const _businessTypeOptions = <Map<String, String>>[
    {'label': 'Products', 'value': 'products'},
    {'label': 'Services', 'value': 'services'},
    {'label': 'Both (Products & Services)', 'value': 'both'},
  ];

  static const _joinOptions = <Map<String, String>>[
    {'label': 'City Igloo (In-person / Online)', 'value': 'city'},
    {'label': 'Pan India Igloo (Online)', 'value': 'pan_india'},
    {'label': 'International Igloo (Online)', 'value': 'international'},
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _businessNameController.dispose();
    _yearsInBusinessController.dispose();
    _gstController.dispose();
    _websiteController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);

    final res = await _common.fetchBusinessCategories();

    if (!mounted) return;

    switch (res) {
      case Ok(value: final value):
        setState(() {
          _categories = value;
          _isLoadingCategories = false;
        });
        break;
      case Err(message: final msg, code: _):
        context.showToast(msg, bg: Colors.red);
        setState(() => _isLoadingCategories = false);
        break;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      context.showToast('Fix validation errors');
      return;
    }

    if (_selectedCategory == null) {
      context.showToast('Please select a business category');
      return;
    }

    if (_selectedBusinessType == null) {
      context.showToast('Please select your business type');
      return;
    }

    if (_selectedJoinPreference == null) {
      context.showToast('Please choose a joining preference');
      return;
    }

    setState(() => _isSubmitting = true);

    final body = {
      'user_type': 'visitor',
      'full_name': _fullNameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'business_name': _businessNameController.text.trim(),
      'business_category': _selectedCategory!.id,
      'business_type': _selectedBusinessType,
      'years_in_business': _yearsInBusinessController.text.trim(),
      'contact': _contactController.text.trim(),
      'gst': _gstController.text.trim(),
      'website': _websiteController.text.trim(),
      'payment_done': _paymentDone ? 1 : 0,
      'want_to_join': _selectedJoinPreference,
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
              "Unauthorized request. Please try again or contact support.";
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
          Container(color: Colors.black.withOpacity(0.3)),
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
                  color: Colors.white.withOpacity(0.94),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                width: 400,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Visitor Registration',
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
                          controller: _businessNameController,
                          decoration: _fieldDecoration('Business Name *'),
                          validator: (v) =>
                              Validators.required(v, label: 'Business Name'),
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
                          decoration: _fieldDecoration('Business Category *'),
                          validator: (value) {
                            if (_categories.isEmpty) {
                              return 'Business categories unavailable';
                            }
                            if (value == null) {
                              return 'Select business category';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedBusinessType,
                          items: _businessTypeOptions
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item['value'],
                                  child: Text(item['label'] ?? ''),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedBusinessType = value),
                          decoration: _fieldDecoration('Business Type *'),
                          validator: (value) =>
                              value == null ? 'Select business type' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _yearsInBusinessController,
                          decoration: _fieldDecoration('Years in Business *'),
                          keyboardType: TextInputType.number,
                          validator: (v) => Validators.required(
                            v,
                            label: 'Years in Business',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _gstController,
                          decoration: _fieldDecoration('GST Number'),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _websiteController,
                          decoration: _fieldDecoration('Website'),
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: _fieldDecoration('Email *'),
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
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
                          controller: _contactController,
                          decoration: _fieldDecoration('Contact Number *'),
                          keyboardType: TextInputType.phone,
                          validator: (v) =>
                              Validators.required(v, label: 'Contact Number'),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedJoinPreference,
                          items: _joinOptions
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item['value'],
                                  child: Text(item['label'] ?? ''),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedJoinPreference = value),
                          decoration: _fieldDecoration(
                            'Preferred SNOW Igloo *',
                          ),
                          validator: (value) => value == null
                              ? 'Select joining preference'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          value: _paymentDone,
                          activeColor: const Color(0xFF5E9BC8),
                          onChanged: (value) =>
                              setState(() => _paymentDone = value),
                          title: const Text('Payment Completed'),
                          subtitle: const Text('Toggle on if payment is done'),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5E9BC8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              minimumSize: const Size(double.infinity, 50),
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
                          onPressed: _isLoadingCategories
                              ? null
                              : _loadCategories,
                          child: const Text('Refresh categories'),
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
