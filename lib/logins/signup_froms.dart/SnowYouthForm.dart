import 'package:flutter/material.dart';

class SnowYouthFormPage extends StatefulWidget {
  const SnowYouthFormPage({super.key});

  @override
  State<SnowYouthFormPage> createState() => _SnowYouthFormPageState();
}

class _SnowYouthFormPageState extends State<SnowYouthFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _educationController = TextEditingController();
  final _schoolController = TextEditingController();
  final _interestController = TextEditingController();
  final _futurePlanController = TextEditingController();
  final _innovationController = TextEditingController();
  final _cityController = TextEditingController();

  bool _isLoading = false;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SnowYouth form submitted!')),
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
                          'SnowYouth Registration',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF5E9BC8)),
                        ),
                        const SizedBox(height: 24),

                        // Full Name
                        TextFormField(
                          controller: _fullNameController,
                          decoration: const InputDecoration(
                              hintText: 'Full Name', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Enter Full Name' : null,
                        ),
                        const SizedBox(height: 16),

                        // Age
                        TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              hintText: 'Age', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Enter Age' : null,
                        ),
                        const SizedBox(height: 16),

                        // Education Completed
                        TextFormField(
                          controller: _educationController,
                          decoration: const InputDecoration(
                              hintText: 'Education Completed', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Enter Education' : null,
                        ),
                        const SizedBox(height: 16),

                        // School / College Name
                        TextFormField(
                          controller: _schoolController,
                          decoration: const InputDecoration(
                              hintText: 'School / College Name', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Enter School / College Name' : null,
                        ),
                        const SizedBox(height: 16),

                        // Interest In
                        TextFormField(
                          controller: _interestController,
                          decoration: const InputDecoration(
                              hintText: 'Interest In', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Enter Interests' : null,
                        ),
                        const SizedBox(height: 16),

                        // Future Plan
                        TextFormField(
                          controller: _futurePlanController,
                          decoration: const InputDecoration(
                              hintText: 'Future Plan', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Enter Future Plan' : null,
                        ),
                        const SizedBox(height: 16),

                        // Any Innovation Ideas
                        TextFormField(
                          controller: _innovationController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                              hintText: 'Any Innovation Ideas', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Enter Innovation Ideas' : null,
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
