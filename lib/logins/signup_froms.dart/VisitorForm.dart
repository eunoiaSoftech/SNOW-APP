import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VisitorFormPage extends StatefulWidget {
  const VisitorFormPage({super.key});

  @override
  State<VisitorFormPage> createState() => _VisitorFormPageState();
}

class _VisitorFormPageState extends State<VisitorFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessCategoryController = TextEditingController();
  final _yearsInBusinessController = TextEditingController();
  final _gstController = TextEditingController();
  final _websiteController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _pinController = TextEditingController();
  final _sponsorController = TextEditingController();
  final _paymentController = TextEditingController();

  // Dropdown/Radio selections
  String? _businessType;
  bool _partOfNetwork = false;
  String? _iglooSelection;
  List<String> _businessOpportunities = [];
  DateTime? _selectedDate;
  int? _recommendScore;
  int _selectedScore = 5;

  bool _isLoading = false;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Visitor form submitted!')));
    });
  }

  Future<void> _pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF5E9BC8), width: 1.5),
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
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
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

                        // Full Name
                        TextFormField(
                          controller: _nameController,
                          decoration: _inputDecoration('Full Name *'),
                          validator: (v) => v!.isEmpty ? 'Enter Name' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _businessNameController,
                          decoration: _inputDecoration('Business Name *'),
                          validator: (v) =>
                              v!.isEmpty ? 'Enter Business Name' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _businessCategoryController,
                          decoration: _inputDecoration('Business Category'),
                        ),
                        const SizedBox(height: 16),

                        // Business Type Radio
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Business Type',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFBDBDBD),
                                ),
                              ),
                              child: Column(
                                children: [
                                  RadioListTile<String>(
                                    title: const Text('Products'),
                                    value: 'Products',
                                    groupValue: _businessType,
                                    onChanged: (v) =>
                                        setState(() => _businessType = v),
                                  ),
                                  RadioListTile<String>(
                                    title: const Text('Services'),
                                    value: 'Services',
                                    groupValue: _businessType,
                                    onChanged: (v) =>
                                        setState(() => _businessType = v),
                                  ),
                                  RadioListTile<String>(
                                    title: const Text(
                                      'Both (Products & Services)',
                                    ),
                                    value: 'Both',
                                    groupValue: _businessType,
                                    onChanged: (v) =>
                                        setState(() => _businessType = v),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _yearsInBusinessController,
                          decoration: _inputDecoration(
                            'How many years in Business',
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _gstController,
                          decoration: _inputDecoration('GST Number (If any)'),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _websiteController,
                          decoration: _inputDecoration('Website'),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _emailController,
                          decoration: _inputDecoration('Email'),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _contactController,
                          decoration: _inputDecoration('Contact Number'),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _addressController,
                          decoration: _inputDecoration('Address'),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _stateController,
                          decoration: _inputDecoration('State'),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _cityController,
                          decoration: _inputDecoration('City'),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _pinController,
                          decoration: _inputDecoration('PIN Code'),
                        ),
                        const SizedBox(height: 16),

                        SwitchListTile(
                          title: const Text(
                            'Are you part of any other Networking Organizations?',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          value: _partOfNetwork,
                          onChanged: (v) => setState(() => _partOfNetwork = v),
                          activeColor: const Color(0xFF5E9BC8),
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          decoration: _inputDecoration(
                            'Join the following SNOW IGLOO',
                          ),
                          value: _iglooSelection,
                          isExpanded: true, // 👈 This is the main fix!
                          items: const [
                            DropdownMenuItem(
                              value: 'CITY IGLOO',
                              child: Text(
                                'CITY IGLOO (Inperson / Online)',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'PAN INDIA IGLOO',
                              child: Text(
                                'PAN INDIA IGLOO (Online)',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'INTERNATIONAL IGLOO',
                              child: Text(
                                'INTERNATIONAL IGLOO (Online)',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          onChanged: (v) => setState(() => _iglooSelection = v),
                        ),

                        const SizedBox(height: 16),

                        // Business Opportunities
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Business opportunities you are looking for?',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFBDBDBD),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  for (final opt in [
                                    'Distributor',
                                    'Collaboration',
                                    'Franchisee',
                                    'Corporates',
                                  ])
                                    CheckboxListTile(
                                      title: Text(opt),
                                      value: _businessOpportunities.contains(
                                        opt,
                                      ),
                                      onChanged: (v) {
                                        setState(() {
                                          if (v == true) {
                                            _businessOpportunities.add(opt);
                                          } else {
                                            _businessOpportunities.remove(opt);
                                          }
                                        });
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _sponsorController,
                          decoration: _inputDecoration(
                            'Name of Sponsor / Invited by',
                          ),
                        ),
                        const SizedBox(height: 16),

                        InkWell(
                          onTap: _pickDate,
                          child: InputDecorator(
                            decoration: _inputDecoration(
                              'Date of form submission',
                            ),
                            child: Text(
                              _selectedDate == null
                                  ? 'Select Date'
                                  : DateFormat(
                                      'MM/dd/yyyy',
                                    ).format(_selectedDate!),
                              style: TextStyle(
                                fontSize: 16,
                                color: _selectedDate == null
                                    ? Colors.grey.shade600
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          'How likely are you to recommend SNOW to business owners, startups, innovators or entrepreneurs?',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            bool isSelected = index <= _selectedScore;

                            // Calculate color based on index: red → yellow → green
                            Color backgroundColor;
                            double fraction = index / 5; // 0 to 1
                            if (fraction < 0.5) {
                              // Red to yellow
                              backgroundColor = Color.lerp(
                                Colors.redAccent.withOpacity(0.5),
                                Colors.yellowAccent.withOpacity(0.5),
                                fraction * 2,
                              )!;
                            } else {
                              // Yellow to green
                              backgroundColor = Color.lerp(
                                Colors.yellowAccent.withOpacity(0.5),
                                Colors.greenAccent.withOpacity(0.5),
                                (fraction - 0.5) * 2,
                              )!;
                            }

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedScore = index;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? backgroundColor
                                      : Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '$index',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [Text('Low'), Text('High')],
                        ),
                        const SizedBox(height: 16),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                'Scan QR Code for Payment',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/QRsacnner.jpg',
                                // height: ,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

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
