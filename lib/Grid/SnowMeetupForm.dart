import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SnowMeetupScreen extends StatefulWidget {
  @override
  _SnowMeetupScreenState createState() => _SnowMeetupScreenState();
}

class _SnowMeetupScreenState extends State<SnowMeetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<Color> gradientColors = [Color(0xFFEAF5FC), Color(0xFFD8E7FA)];

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

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF5FC),
        elevation: 0,
        title: Text(
          "SNOW MEETUP'S",
          style: GoogleFonts.poppins(
            color: const Color(0xFF014576),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildLabel('TO'),
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
                      style: GoogleFonts.poppins(color: Colors.black),
                      value: selectedTo,
                      hint: Text(
                        'Select recipient',
                        style: GoogleFonts.poppins(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                      decoration: InputDecoration.collapsed(hintText: ''),
                      borderRadius: BorderRadius.circular(12),
                      items: toItems.map((e) {
                        return DropdownMenuItem<String>(
                          value: e['value'],
                          child: Text(
                            e['label']!,
                            style: GoogleFonts.poppins(),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => selectedTo = val),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                buildLabel('Date'),
                TextFormField(
                  controller: dateController,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: InputDecoration(
                    hintText: 'Eg: 25-07-2025',
                    hintStyle: GoogleFonts.poppins(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16),

                buildLabel('Collaboration'),
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
                      style: GoogleFonts.poppins(color: Colors.black),
                      value: selectedCollaboration,
                      hint: Text(
                        'Select',
                        style: GoogleFonts.poppins(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                      decoration: InputDecoration.collapsed(hintText: ''),
                      borderRadius: BorderRadius.circular(12),
                      items: collaborationItems.map((e) {
                        return DropdownMenuItem<String>(
                          value: e['value'],
                          child: Text(
                            e['label']!,
                            style: GoogleFonts.poppins(),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => selectedCollaboration = val),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                buildLabel('Mode of meet'),
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
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      value: selectedMode,
                      hint: Text(
                        'Select',
                        style: GoogleFonts.poppins(color: Colors.black54),
                      ),
                      decoration: InputDecoration.collapsed(hintText: ''),
                      borderRadius: BorderRadius.circular(12),
                      items: ['Online', 'Offline'].map((e) {
                        return DropdownMenuItem<String>(
                          value: e,
                          child: Text(e, style: GoogleFonts.poppins()),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => selectedMode = val),
                    ),
                  ),
                ),
                SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
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
                            backgroundColor: gradientColors[0],
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
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          'Submit',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
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
    );
  }
}
