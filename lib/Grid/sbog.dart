import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/Data/Repositories/referrals_repository.dart';
import 'package:snow_app/Data/Repositories/common_repository.dart';
import 'package:snow_app/core/result.dart';
import '../Data/models/business_category.dart';
import '../Data/models/business_item.dart';
import '../core/api_client.dart';

class RecordSBOGScreen extends StatefulWidget {
  const RecordSBOGScreen({Key? key}) : super(key: key);

  @override
  _RecordSBOGScreenState createState() => _RecordSBOGScreenState();
}

class _RecordSBOGScreenState extends State<RecordSBOGScreen> {
  final _formKey = GlobalKey<FormState>();
  final _leadNameController = TextEditingController();
  final _leadEmailController = TextEditingController();
  final _leadPhoneController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingBusinesses = true;

  final repository = ReferralsRepository(ApiClient.create());
  final commonRepository = CommonRepository();

  List<CustomBusinessItem> _businessList = [];
  CustomBusinessItem? _selectedBusiness;

  @override
  void initState() {
    super.initState();
    _fetchBusinessCategories();
  }

Future<void> _fetchBusinessCategories() async {
  try {
    setState(() => _isLoadingBusinesses = true);

    final result = await commonRepository.fetchBusiness();

    if (result is Ok<List<CustomBusinessItem>>) {
      setState(() {
        _businessList = result.value;
      });
    } else if (result is Err) {
      final errorValue = (result as Err).message ?? 'Failed to load categories';
      setState(() => _isLoadingBusinesses = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorValue.toString(),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    setState(() => _isLoadingBusinesses = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Something went wrong: $e',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    setState(() => _isLoadingBusinesses = false);
  }
}


  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF014576),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedBusiness == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a business.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await repository.createSbog(
        receiverId: _selectedBusiness!.id!,
        leadName: _leadNameController.text,
        leadEmail: _leadEmailController.text,
        leadPhone: _leadPhoneController.text,
        message: _messageController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image with gradient
        Positioned.fill(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/bghome.jpg', fit: BoxFit.cover),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xAA97DCEB),
                      Color(0xAA5E9BC8),
                      Color(0xAA97DCEB),
                      Color(0xAA70A9EE),
                      Color(0xAA97DCEB),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ],
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              "RECORD SBOG",
              style: GoogleFonts.poppins(
                color: const Color(0xFF014576),
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            iconTheme: const IconThemeData(color: Color(0xFF014576)),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFFEAF5FC), Color(0xFFD8E7FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildLabel('Select Business'),
                      _isLoadingBusinesses
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<CustomBusinessItem>(
    isExpanded: true, // allows the dropdown to take full width
    value: _selectedBusiness,
    items: _businessList
        .map((b) => DropdownMenuItem(
    value: b,
    child: Text(
    b.business?.name ?? '-',
    style: GoogleFonts.poppins(),
    overflow: TextOverflow.ellipsis, // prevents overflow
    ),
    ))
        .toList(),
    onChanged: (value) {
    setState(() => _selectedBusiness = value);
    },
    decoration: _inputDecoration('Choose business'),
    validator: (v) => v == null ? 'Please select a business' : null,
    ),

                      const SizedBox(height: 16),

                      buildLabel('Lead Name'),
                      TextFormField(
                        controller: _leadNameController,
                        decoration: _inputDecoration('Enter lead name'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),

                      buildLabel('Lead Email'),
                      TextFormField(
                        controller: _leadEmailController,
                        decoration: _inputDecoration('Enter lead email'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),

                      buildLabel('Lead Phone'),
                      TextFormField(
                        controller: _leadPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: _inputDecoration('Enter lead phone'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),

                      buildLabel('Message'),
                      TextFormField(
                        controller: _messageController,
                        maxLines: 5,
                        decoration: _inputDecoration('Write your message'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _isLoading ? null : _submitForm,
                          child: Ink(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(170, 141, 188, 222),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      'SUBMIT',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF014576),
                                      ),
                                    ),
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
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
