import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Data/Repositories/referrals_repository.dart';
import '../core/api_client.dart';
import '../Data/models/sfg_response.dart';

class RecordSFGScreen extends StatefulWidget {
  final int leadId;
  const RecordSFGScreen({required this.leadId, super.key});

  @override
  _RecordSFGScreenState createState() => _RecordSFGScreenState();
}

class _RecordSFGScreenState extends State<RecordSFGScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedStatus;

  final TextEditingController commentController = TextEditingController();
  bool _isSubmitting = false;

  final repo = ReferralsRepository(ApiClient.create());

  final List<Color> gradientColors = [
    Color(0xAA97DCEB),
    Color(0xAA5E9BC8),
    Color(0xAA97DCEB),
    Color(0xAA70A9EE),
    Color(0xAA97DCEB),
  ];

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF014576),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a status')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final RecordSfgResponse response = await repo.createSSfg(
        leadId: widget.leadId,
        status: selectedStatus!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // return true to trigger refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image + gradient
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
              "RECORD SFG",
              style: GoogleFonts.poppins(
                color: Color(0xFF014576),
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
                gradient: LinearGradient(
                  colors: [Color(0xFFEAF5FC), Color(0xFFD8E7FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(2, 4),
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
                      buildLabel('STATUS'),
                      DropdownButtonHideUnderline(
                        child: Container(
                          height: 55,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButtonFormField<String>(
                            padding: EdgeInsets.only(top: 15, right: 10),
                            isExpanded: true,
                            icon: Icon(Icons.arrow_drop_up, color: Colors.black87),
                            dropdownColor: Colors.white,
                            style: GoogleFonts.poppins(color: Colors.black, fontSize: 16),
                            value: selectedStatus,
                            hint: Text(
                              'Select status',
                              style: GoogleFonts.poppins(color: Colors.black54),
                            ),
                            decoration: InputDecoration.collapsed(hintText: ''),
                            borderRadius: BorderRadius.circular(12),
                            items: ['successful', 'failed']
                                .map((status) => DropdownMenuItem<String>(
                                      value: status,
                                      child: Text(status, style: GoogleFonts.poppins()),
                                    ))
                                .toList(),
                            onChanged: (val) => setState(() => selectedStatus = val),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      buildLabel('COMMENT'),
                      TextFormField(
                        controller: commentController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Optional comment',
                          hintStyle: GoogleFonts.poppins(),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: 30),
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
                          onPressed: _isSubmitting ? null : _submitForm,
                          child: Ink(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(170, 141, 188, 222),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: _isSubmitting
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                      'Submit',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF014576),
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
