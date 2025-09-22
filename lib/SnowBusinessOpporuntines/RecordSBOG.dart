import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/Data/Repositories/referrals_repository.dart';
import 'package:snow_app/Data/Repositories/common_repository.dart';
import 'package:snow_app/SnowBusinessOpporuntines/_SearchIgloosDialog.dart';

import '../core/api_client.dart';

class RecordSBOG extends StatefulWidget {
  const RecordSBOG({Key? key}) : super(key: key);

  @override
  _RecordSBOGState createState() => _RecordSBOGState();
}

class _RecordSBOGState extends State<RecordSBOG> {
  final _formKey = GlobalKey<FormState>();
  final _referralController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _commentsController = TextEditingController();

  bool _isLoading = false;

  final repository = ReferralsRepository(ApiClient.create());
  final commonRepository = CommonRepository();

  String? _selectedMemberName;
  int _selectedConnectLevel = 0;
  String? _selectedMyIglooMember;

  List<String> _myIglooMembers = ['Member A', 'Member B', 'Member C'];

  @override
  void dispose() {
    _referralController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  void _showIgloosSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return
        
         SearchIgloosDialog(
          onMemberSelected: (memberName) {
            setState(() {
              _selectedMemberName = memberName;
              _selectedMyIglooMember = null;
            });
          },
        );
      },
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate() ||
        (_selectedMemberName == null && _selectedMyIglooMember == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a member and fill all required fields.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Placeholder for API call
    // final response = await repository.createSbog(...);

    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF014576),
              ),
            ),
            TextSpan(
              text: '*',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectLevelRadio({required int value, required String text}) {
    return Row(
      children: [
        Radio<int>(
          value: value,
          groupValue: _selectedConnectLevel,
          onChanged: (int? newValue) {
            setState(() {
              _selectedConnectLevel = newValue!;
            });
          },
          activeColor: const Color(0xFF014576),
        ),
        Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 12))),
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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel(label),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: _inputDecoration(hint),
          validator: (value) => value!.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline_rounded, color: Color(0xFF014576)),
                onPressed: _showIgloosSearchDialog,
              ),
            ],
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
                      // Inside your RecordSBOG build method, replace the "To" section with this:
                      // buildLabel('To'),
                              // ---------------- "To" Text Field ----------------
_buildTextField('To', _referralController, 'Enter recipient name'),

// ---------------- My Igloo Member Dropdown ----------------
buildLabel('Select a member from My Igloo'),
DropdownButtonFormField<String>(
  value: _selectedMyIglooMember,
  items: _myIglooMembers.map((String member) {
    return DropdownMenuItem<String>(
      value: member,
      child: Text(
        member,
        style: GoogleFonts.poppins(fontSize: 14),
      ),
    );
  }).toList(),
  onChanged: (String? newValue) {
    setState(() {
      _selectedMyIglooMember = newValue;
    });
  },
  decoration: _inputDecoration('Select a member'),
  validator: (value) {
    if (value == null) {
      return 'Required';
    }
    return null;
  },
),

  const SizedBox(height: 16),
                      if (_selectedMemberName != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            'Selected: $_selectedMemberName',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      _buildTextField('Referral', _referralController, ''),
                      _buildTextField(
                        'Telephone',
                        _telephoneController,
                        '',
                        keyboardType: TextInputType.phone,
                      ),
                      _buildTextField('Email', _emailController, ''),

                      buildLabel('Level of Connect'),
                      _buildConnectLevelRadio(
                        value: 1,
                        text:
                            'Member passes on the contact no of prospective lead or customer.',
                      ),
                      _buildConnectLevelRadio(
                        value: 2,
                        text:
                            'Member Introduce over a con call to prospective lead or customer.',
                      ),
                      _buildConnectLevelRadio(
                        value: 3,
                        text:
                            'Member arranges an online meeting of prospective lead or customer with fellow member.',
                      ),
                      _buildConnectLevelRadio(
                        value: 4,
                        text:
                            'Member takes along with him the fellow SNOWEIT to prospective lead or customer for in person meeting.',
                      ),
                      _buildConnectLevelRadio(
                        value: 5,
                        text:
                            'Member takes along with the fellow SNOWEIT to prospective lead or customer and finalies the deal.',
                      ),
                      const SizedBox(height: 16),

                      buildLabel('Comments'),
                      TextFormField(
                        controller: _commentsController,
                        maxLines: 5,
                        decoration: _inputDecoration('Write your comments'),
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
}

