import 'package:flutter/material.dart';
import 'package:snow_app/Data/Models/business_category.dart';
import 'package:snow_app/Data/Repositories/auth_repository.dart';
import 'package:snow_app/Data/Repositories/common_repository.dart';
import 'package:snow_app/core/app_toast.dart';
import 'package:snow_app/core/result.dart';
import 'package:snow_app/core/validators.dart';
import 'package:snow_app/home/dashboard.dart';

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

  final _auth = AuthRepository();
  final _common = CommonRepository();

  BusinessCategory? _selectedCategory;
  List<BusinessCategory> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final res = await _common.fetchBusinessCategories();
    if (res is Ok<List<BusinessCategory>>) {
      setState(() => _categories = res.value);
    } else if (res is Err) {
      context.showToast('Failed to load categories', bg: Colors.red);
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
      if (_businessNameController.text.isNotEmpty) 'business_name': _businessNameController.text.trim(),
      if (_selectedCategory != null) 'business_category': _selectedCategory!.id,
      if (_contactController.text.isNotEmpty) 'contact': _contactController.text.trim(),
      if (_cityController.text.isNotEmpty) 'city': _cityController.text.trim(),
    };

    final res = await _auth.signup(body);

    setState(() => _isLoading = false);

    switch (res) {
      case Ok(value: final v):
        context.showToast(v.message);
         Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SnowDashboard()),
          (Route<dynamic> route) => false,
        );
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
              padding: const EdgeInsets.only(top: 55, left: 25, right: 25, bottom: 45),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
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
                          'SIGN UP',
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
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                          validator: (v) => Validators.required(v, label: 'Full Name'),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            hintText: 'Email *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
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
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                          validator: (v) => Validators.minLen(v, 6, label: 'Password'),
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<BusinessCategory>(
                          value: _selectedCategory,
                          items: _categories
                              .map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c.name),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedCategory = v),
                          decoration: const InputDecoration(
                            labelText: 'Business Category (optional)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _businessNameController,
                          decoration: const InputDecoration(
                            hintText: 'Business Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _contactController,
                          decoration: const InputDecoration(
                            hintText: 'Contact',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(
                            hintText: 'City',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
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
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Submit',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
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
