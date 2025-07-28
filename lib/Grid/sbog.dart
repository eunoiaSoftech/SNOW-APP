import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecordSBOGScreen extends StatefulWidget {
  @override
  _RecordSBOGScreenState createState() => _RecordSBOGScreenState();
}

class _RecordSBOGScreenState extends State<RecordSBOGScreen> {
  String? selectedLevel;
  final _formKey = GlobalKey<FormState>();
  final List<Color> gradientColors = [Color(0xFFEAF5FC), Color(0xFFD8E7FA)];

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Record SBOG",
          style: GoogleFonts.poppins(
            color: const Color(0xFF014576),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFFEAF5FC),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildLabel('To'),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Enter recipient name',
                    hintStyle: GoogleFonts.poppins(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                buildLabel('Referral'),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Enter referral info',
                    hintStyle: GoogleFonts.poppins(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                buildLabel('Level'),
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
                      value: selectedLevel,
                      hint: Text(
                        'Select level',
                        style: GoogleFonts.poppins(color: Colors.black54),
                      ),
                      decoration: InputDecoration.collapsed(hintText: ''),
                      borderRadius: BorderRadius.circular(12),
                      items: ['Level 1', 'Level 2', 'Level 3']
                          .map(
                            (e) => DropdownMenuItem<String>(
                              value: e,
                              child: Text(e, style: GoogleFonts.poppins()),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => selectedLevel = val),
                    ),
                  ),
                ),

                SizedBox(height: 16),
                buildLabel('Comment'),
                TextFormField(
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Write your thoughts here...',

                    hintStyle: GoogleFonts.poppins(),
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
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Form submitted!',
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
