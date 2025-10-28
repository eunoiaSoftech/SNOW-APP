import 'package:flutter/material.dart';

class SnowRealEstateFormPage extends StatefulWidget {
  const SnowRealEstateFormPage({super.key});

  @override
  State<SnowRealEstateFormPage> createState() => _SnowRealEstateFormPageState();
}

class _SnowRealEstateFormPageState extends State<SnowRealEstateFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessCategoryController = TextEditingController();
  final _citiesController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _cityController = TextEditingController();

  bool _isLoading = false;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SnowRealEstate form submitted!')),
      );
    });
  }

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
                    BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5)),
                  ],
                ),
                child: SingleChildScrollView(
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
                              color: Color(0xFF5E9BC8)),
                        ),
                        const SizedBox(height: 24),

                        // Full Name
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                              hintText: 'Full Name', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Enter Full Name' : null,
                        ),
                        const SizedBox(height: 16),

                        // Business Name
                        TextFormField(
                          controller: _businessNameController,
                          decoration: const InputDecoration(
                              hintText: 'Business Name', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Enter Business Name' : null,
                        ),
                        const SizedBox(height: 16),

                        // Business Category
                        TextFormField(
                          controller: _businessCategoryController,
                          decoration: const InputDecoration(
                              hintText: 'Business Category', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Enter Business Category' : null,
                        ),
                        const SizedBox(height: 16),

                        // Cities of Operation
                        TextFormField(
                          controller: _citiesController,
                          decoration: const InputDecoration(
                              hintText: 'Cities you operate in', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Enter Cities' : null,
                        ),
                        const SizedBox(height: 16),

                        // Contact Number
                        TextFormField(
                          controller: _contactController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                              hintText: 'Contact Number', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Enter Contact Number' : null,
                        ),
                        const SizedBox(height: 16),

                        // Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                              hintText: 'Email Id', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Enter Email' : null,
                        ),
                        const SizedBox(height: 16),

                        // Website (optional)
                        TextFormField(
                          controller: _websiteController,
                          decoration: const InputDecoration(
                              hintText: 'Website (if any)', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 16),

                        // City
                        TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(
                              hintText: 'City', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Enter City' : null,
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5E9BC8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Submit',
                                  style: TextStyle(color: Colors.white, fontSize: 16)),
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
