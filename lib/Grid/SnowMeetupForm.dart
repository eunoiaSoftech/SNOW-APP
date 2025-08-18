import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SnowMeetupScreen extends StatefulWidget {
  @override
  _SnowMeetupScreenState createState() => _SnowMeetupScreenState();
}

class _SnowMeetupScreenState extends State<SnowMeetupScreen> {
  final _formKey = GlobalKey<FormState>();

  String? selectedTo;
  String? selectedCollaboration;
  String? selectedMode;

  final TextEditingController dateController = TextEditingController();

  final List<Map<String, String>> toItems = [
    {'label': 'Other IGLOO', 'value': 'to_other_igloo'},
    {'label': 'Abstract', 'value': 'to_abstract'},
  ];

  final List<Map<String, String>> collaborationItems = [
    {'label': 'Other IGLOO', 'value': 'collab_other_igloo'},
    {'label': 'Abstract', 'value': 'collab_abstract'},
  ];

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF014576),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        dateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image + gradient overlay
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

        // Foreground content
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              "SNOW MEETUP'S",
              style: GoogleFonts.poppins(
                color: Color(0xFF014576),
                fontWeight: FontWeight.w600,
                fontSize: 20,
                shadows: [
                  Shadow(
                    blurRadius: 4,
                    color: Color.fromARGB(150, 200, 240, 255),
                    offset: Offset(1, 2),
                  ),
                ],
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
                      buildLabel('TO'),
                      _buildDropdownField(
                        items: toItems,
                        value: selectedTo,
                        hint: 'Select recipient',
                        onChanged: (val) => setState(() => selectedTo = val),
                      ),
                      SizedBox(height: 16),

                      buildLabel('DATE'),
                      TextFormField(
                        controller: dateController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        decoration: InputDecoration(
                          hintText: 'Eg: 25-07-2025',
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
                      SizedBox(height: 16),

                      buildLabel('COLLABORATION'),
                      _buildDropdownField(
                        items: collaborationItems,
                        value: selectedCollaboration,
                        hint: 'Select',
                        onChanged: (val) =>
                            setState(() => selectedCollaboration = val),
                      ),
                      SizedBox(height: 16),

                      buildLabel('MODE OF MEET'),
                      _buildDropdownField(
                        items: [
                          {'label': 'Online', 'value': 'Online'},
                          {'label': 'Offline', 'value': 'Offline'}
                        ],
                        value: selectedMode,
                        hint: 'Select',
                        onChanged: (val) => setState(() => selectedMode = val),
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
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Meetup created successfully!',
                                    style: TextStyle(
                                      color: Color(0xFF014576),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: Colors.white,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          },
                          child: Ink(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(170, 141, 188, 222),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
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

  Widget _buildDropdownField({
    required List<Map<String, String>> items,
    required String? value,
    required String hint,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonHideUnderline(
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
          style: GoogleFonts.poppins(color: Colors.black),
          value: value,
          hint: Text(hint,
              style: GoogleFonts.poppins(color: Colors.black54, fontSize: 16)),
          decoration: InputDecoration.collapsed(hintText: ''),
          borderRadius: BorderRadius.circular(12),
          items: items.map((e) {
            return DropdownMenuItem<String>(
              value: e['value'],
              child: Text(e['label']!, style: GoogleFonts.poppins()),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
