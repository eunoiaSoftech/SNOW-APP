import 'package:flutter/material.dart';
import 'package:snow_app/Data/Models/business_category.dart';
import 'package:snow_app/Data/Repositories/auth_repository.dart';
import 'package:snow_app/Data/Repositories/common_repository.dart';
import 'package:snow_app/Data/models/New%20Model/DirectoryUsermodel.dart';
import 'package:snow_app/common%20api/all_business_directory_model.dart';
import 'package:snow_app/core/app_toast.dart';
import 'package:snow_app/core/result.dart';
import 'package:snow_app/core/validators.dart';
import 'package:snow_app/home/showSearchablePicker.dart';
import 'package:snow_app/logins/login.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class VisitorFormPage extends StatefulWidget {
  const VisitorFormPage({super.key});

  @override
  State<VisitorFormPage> createState() => _VisitorFormPageState();
}

class _VisitorFormPageState extends State<VisitorFormPage> {
  final _formKey = GlobalKey<FormState>();
  File? _aadharFile;
  final ImagePicker _picker = ImagePicker();

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
  List<DirectoryUserPublic> _members = [];
  int? _selectedReferrerId;
  bool _isMembersLoading = false;
  bool _isLoadingCategories = false;
  bool _isSubmitting = false;
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
    _loadMembers();
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

  Future<void> _loadMembers() async {
    setState(() => _isMembersLoading = true);

    try {
      final list = await _common.fetchDirectoryUsersPublic();

      // ✅ REMOVE DUPLICATES
      final uniqueMap = <int, DirectoryUserPublic>{};

      for (var m in list) {
        uniqueMap[m.id] = m;
      }

      setState(() {
        _members = uniqueMap.values.toList();
        _selectedReferrerId = null;
        _isMembersLoading = false;
      });
    } catch (e) {
      print("💥 LOAD MEMBERS ERROR: $e");
      setState(() => _isMembersLoading = false);
    }
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
    if (_aadharFile == null) {
      context.showToast('Please upload Aadhaar card', bg: Colors.red);
      return;
    }

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
    if (_selectedReferrerId == null) {
      context.showToast("Please select who invited you");
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
      'user_id': _selectedReferrerId,
    };

    final res = await _auth.signup(body: body, aadharFile: _aadharFile);

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
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 25),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                width: 500, // Increased slightly for better layout
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'Visitor Registration',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5E9BC8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // --- SECTION 1: PERSONAL DETAILS ---
                        _buildSectionHeader(Icons.person, "Personal Details"),
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
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _contactController,
                          decoration: _fieldDecoration('Contact Number *'),
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Contact Number is required';
                            if (!RegExp(r'^\d{10}$').hasMatch(v.trim()))
                              return 'Must be 10 digits';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: _fieldDecoration('Create Password *'),
                          validator: (v) =>
                              Validators.required(v, label: 'Password'),
                        ),

                        const SizedBox(height: 32),
                        // --- SECTION 2: BUSINESS INFORMATION ---
                        _buildSectionHeader(
                          Icons.business,
                          "Business Information",
                        ),
                        TextFormField(
                          controller: _businessNameController,
                          decoration: _fieldDecoration('Business Name *'),
                          validator: (v) =>
                              Validators.required(v, label: 'Business Name'),
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
                          decoration: _fieldDecoration('Business Category *'),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Align for validation errors
                          children: [
                            Expanded(
                              flex: 3, // Gives more space to the dropdown
                              child: DropdownButtonFormField<String>(
                                isExpanded:
                                    true, // Prevents text from pushing outside
                                value: _selectedBusinessType,
                                items: _businessTypeOptions
                                    .map(
                                      (item) => DropdownMenuItem<String>(
                                        value: item['value'],
                                        child: Text(
                                          item['label'] ?? '',
                                          overflow: TextOverflow
                                              .ellipsis, // Clips long text
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) => setState(
                                  () => _selectedBusinessType = value,
                                ),
                                decoration: _fieldDecoration('Type *').copyWith(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 12,
                                  ),
                                ),
                                validator: (value) =>
                                    value == null ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2, // Slightly smaller for the number field
                              child: TextFormField(
                                controller: _yearsInBusinessController,
                                decoration: _fieldDecoration('Years *')
                                    .copyWith(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 12,
                                          ),
                                    ),
                                keyboardType: TextInputType.number,
                                validator: (v) =>
                                    Validators.required(v, label: 'Years'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _gstController,
                          decoration: _fieldDecoration('GST Number (Optional)'),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _websiteController,
                          decoration: _fieldDecoration('Website (Optional)'),
                        ),

                        const SizedBox(height: 32),
                        // --- SECTION 3: VERIFICATION & REFERRAL ---
                        _buildSectionHeader(
                          Icons.verified_user,
                          "Verification",
                        ),
                        _buildReferralPicker(context),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedJoinPreference,
                          items: _joinOptions
                              .map(
                                (item) => DropdownMenuItem(
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
                        ),
                        const SizedBox(height: 20),

                        // Aadhaar Upload
                        const Text(
                          "Proof of Identity",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _buildFileUploadTile(),

                        const SizedBox(height: 16),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _paymentDone,
                          activeColor: const Color(0xFF5E9BC8),
                          onChanged: (value) =>
                              setState(() => _paymentDone = value),
                          title: const Text('Payment Completed'),
                          subtitle: const Text(
                            'Confirm if registration fee is paid',
                          ),
                        ),

                        const SizedBox(height: 32),
                        // --- SUBMIT BUTTON ---
                        _buildSubmitButton(),

                        Center(
                          child: TextButton(
                            onPressed: _isLoadingCategories
                                ? null
                                : _loadCategories,
                            child: const Text(
                              'Refresh categories',
                              style: TextStyle(color: Color(0xFF5E9BC8)),
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

  // --- HELPER UI METHODS ---

  Widget _buildSectionHeader(IconData icon, String title) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF5E9BC8)),
            const SizedBox(width: 8),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF5E9BC8),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const Divider(thickness: 1, height: 20),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildReferralPicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            final selected = await showSearchablePicker(
              context: context,
              items: _members,
              title: "Select Member",
              label: (m) => "${m.fullName} - ${m.businessName}",
            );
            if (selected != null) {
              setState(() => _selectedReferrerId = selected.id);
            }
          },
          child: InputDecorator(
            // This makes the picker look exactly like your TextFormFields
            decoration: _fieldDecoration(
              'Invited by Member *',
            ).copyWith(suffixIcon: const Icon(Icons.arrow_drop_down)),
            child: Text(
              _selectedReferrerId == null
                  ? "Select a member"
                  : _members
                        .firstWhere((e) => e.id == _selectedReferrerId)
                        .fullName,
              style: TextStyle(
                color: _selectedReferrerId == null
                    ? Colors.grey[600]
                    : Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadTile() {
    return InkWell(
      onTap: _pickAadhar,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: _aadharFile == null ? Colors.grey.shade400 : Colors.green,
          ),
          borderRadius: BorderRadius.circular(12),
          color: _aadharFile == null
              ? Colors.grey.shade50
              : Colors.green.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Icon(
              Icons.upload_file,
              color: _aadharFile == null
                  ? const Color(0xFF5E9BC8)
                  : Colors.green,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _aadharFile == null
                    ? 'Upload Aadhaar image'
                    : 'Aadhaar selected ✔',
                style: TextStyle(
                  color: _aadharFile == null ? Colors.grey[700] : Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5E9BC8),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 54),
        elevation: 2,
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
              'Complete Registration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
    );
  }
}
