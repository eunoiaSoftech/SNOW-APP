import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:snow_app/Data/Repositories/MeetupRepository.dart';
import 'package:snow_app/core/api_client.dart';

class SnowMeetupScreen extends StatefulWidget {
  @override
  _SnowMeetupScreenState createState() => _SnowMeetupScreenState();
}

class _SnowMeetupScreenState extends State<SnowMeetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final MeetupRepository meetupRepository = MeetupRepository(
    ApiClient.create(),
  );

  // Controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController venueNameController = TextEditingController();
  final TextEditingController venueAddressController = TextEditingController();
  final TextEditingController venueCityController = TextEditingController();
  final TextEditingController venueStateController = TextEditingController();
  final TextEditingController venueCountryController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController contactNameController = TextEditingController();
  final TextEditingController contactEmailController = TextEditingController();
  final TextEditingController contactPhoneController = TextEditingController();

  bool isPaid = false;

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
        dateController.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(picked);
      });
    }
  }

Future<void> _submitMeetup() async {
  if (_formKey.currentState!.validate()) {
    final Map<String, dynamic> body = {
      "title": titleController.text.trim(),
      "description": descriptionController.text.trim(),
      "venue_name": venueNameController.text.trim(),
      "venue_address": venueAddressController.text.trim(),
      "venue_city": venueCityController.text.trim(),
      "venue_state": venueStateController.text.trim(),
      "venue_country": venueCountryController.text.trim(),
      "venue_latitude": latitudeController.text.trim(),
      "venue_longitude": longitudeController.text.trim(),
      "date": dateController.text.trim(),
      "capacity": int.tryParse(capacityController.text.trim()) ?? 0,
      "is_paid": isPaid,
      "price": isPaid ? double.tryParse(priceController.text.trim()) ?? 0 : 0,
      "contact_name": contactNameController.text.trim(),
      "contact_email": contactEmailController.text.trim(),
      "contact_phone": contactPhoneController.text.trim(),
    };

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submitting meetup...')),
      );

      final meetup = await meetupRepository.createMeetup(body);

      Navigator.pop(context, true); // ✅ Pop screen and return true

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}


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
              "CREATE MEETUP",
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
                      buildLabel('TITLE'),
                      _buildTextField(
                        "Title",
                        titleController,
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                      SizedBox(height: 16),

                      buildLabel('DESCRIPTION'),
                      _buildTextField(
                        "Description",
                        descriptionController,
                        validator: (v) => v!.length < 10 ? "Too short" : null,
                      ),
                      SizedBox(height: 16),

                      buildLabel('VENUE NAME'),
                      _buildTextField(
                        "Venue Name",
                        venueNameController,
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                      SizedBox(height: 16),

                      buildLabel('VENUE ADDRESS'),
                      _buildTextField(
                        "Venue Address",
                        venueAddressController,
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                      SizedBox(height: 16),

                      buildLabel('CITY'),
                      _buildTextField(
                        "City",
                        venueCityController,
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                      SizedBox(height: 16),

                      buildLabel('STATE'),
                      _buildTextField(
                        "State",
                        venueStateController,
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                      SizedBox(height: 16),

                      buildLabel('COUNTRY'),
                      _buildTextField(
                        "Country",
                        venueCountryController,
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                      SizedBox(height: 16),

                      buildLabel('LATITUDE'),
                      _buildTextField(
                        "Latitude",
                        latitudeController,
                        keyboardType: TextInputType.number,
                        validator: (v) => double.tryParse(v!) == null
                            ? "Invalid latitude"
                            : null,
                      ),
                      SizedBox(height: 16),

                      buildLabel('LONGITUDE'),
                      _buildTextField(
                        "Longitude",
                        longitudeController,
                        keyboardType: TextInputType.number,
                        validator: (v) => double.tryParse(v!) == null
                            ? "Invalid longitude"
                            : null,
                      ),
                      SizedBox(height: 16),

                      buildLabel('DATE'),
                      _buildDatePicker(),
                      SizedBox(height: 16),

                      buildLabel('CAPACITY'),
                      _buildTextField(
                        "Capacity",
                        capacityController,
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            int.tryParse(v!) == null ? "Invalid number" : null,
                      ),
                      SizedBox(height: 16),

                      buildLabel('IS PAID EVENT'),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => isPaid = false),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !isPaid
                                        ? Color(0xFF014576)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Free',
                                      style: GoogleFonts.poppins(
                                        color: !isPaid
                                            ? Colors.white
                                            : Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => isPaid = true),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isPaid
                                        ? Color(0xFF014576)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Paid',
                                      style: GoogleFonts.poppins(
                                        color: isPaid
                                            ? Colors.white
                                            : Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),

                      if (isPaid) ...[
                        buildLabel('PRICE'),
                        TextFormField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (isPaid && (value == null || value.isEmpty)) {
                              return 'Price is required for paid events';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter price in INR',
                            hintStyle: GoogleFonts.poppins(),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        SizedBox(height: 16),
                      ],

                      SizedBox(height: 16),

                      buildLabel('CONTACT NAME'),
                      _buildTextField(
                        "Contact Name",
                        contactNameController,
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                      SizedBox(height: 16),

                      buildLabel('CONTACT EMAIL'),
                      _buildTextField(
                        "Contact Email",
                        contactEmailController,
                        validator: (v) =>
                            !v!.contains('@') ? "Invalid email" : null,
                      ),
                      SizedBox(height: 16),

                      buildLabel('CONTACT PHONE'),
                      _buildTextField(
                        "Contact Phone",
                        contactPhoneController,
                        validator: (v) =>
                            v!.length < 10 ? "Invalid phone" : null,
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
                          onPressed: _submitMeetup,
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: GoogleFonts.poppins(color: Colors.black54),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: _buildTextField(
          "Select Date",
          dateController,
          validator: (v) => v!.isEmpty ? "Required" : null,
        ),
      ),
    );
  }
}






















// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';

// class SnowMeetupScreen extends StatefulWidget {
//   @override
//   _SnowMeetupScreenState createState() => _SnowMeetupScreenState();
// }

// class _SnowMeetupScreenState extends State<SnowMeetupScreen> {
//   final _formKey = GlobalKey<FormState>();

//   String? selectedTo;
//   String? selectedCollaboration;
//   String? selectedMode;

//   final TextEditingController dateController = TextEditingController();

//   final List<Map<String, String>> toItems = [
//     {'label': 'Other IGLOO', 'value': 'to_other_igloo'},
//     {'label': 'Abstract', 'value': 'to_abstract'},
//   ];

//   final List<Map<String, String>> collaborationItems = [
//     {'label': 'Other IGLOO', 'value': 'collab_other_igloo'},
//     {'label': 'Abstract', 'value': 'collab_abstract'},
//   ];

//   final List<Color> gradientColors = [
//     Color(0xAA97DCEB),
//     Color(0xAA5E9BC8),
//     Color(0xAA97DCEB),
//     Color(0xAA70A9EE),
//     Color(0xAA97DCEB),
//   ];

//   Widget buildLabel(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: Text(
//         text,
//         style: GoogleFonts.poppins(
//           fontSize: 14,
//           fontWeight: FontWeight.w600,
//           color: Color(0xFF014576),
//         ),
//       ),
//     );
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2100),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: const Color(0xFF014576),
//               onPrimary: Colors.white,
//               onSurface: Colors.black,
//             ),
//             dialogBackgroundColor: Colors.white,
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null) {
//       setState(() {
//         dateController.text = DateFormat('dd-MM-yyyy').format(picked);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         // Background image + gradient overlay
//         Positioned.fill(
//           child: Stack(
//             fit: StackFit.expand,
//             children: [
//               Image.asset('assets/bghome.jpg', fit: BoxFit.cover),
//               Container(
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Color(0xAA97DCEB),
//                       Color(0xAA5E9BC8),
//                       Color(0xAA97DCEB),
//                       Color(0xAA70A9EE),
//                       Color(0xAA97DCEB),
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // Foreground content
//         Scaffold(
//           backgroundColor: Colors.transparent,
//           appBar: AppBar(
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             title: Text(
//               "SNOW MEETUP'S",
//               style: GoogleFonts.poppins(
//                 color: Color(0xFF014576),
//                 fontWeight: FontWeight.w600,
//                 fontSize: 20,
//                 shadows: [
//                   Shadow(
//                     blurRadius: 4,
//                     color: Color.fromARGB(150, 200, 240, 255),
//                     offset: Offset(1, 2),
//                   ),
//                 ],
//               ),
//             ),
//             iconTheme: const IconThemeData(color: Color(0xFF014576)),
//           ),
//           body: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(20),
//                 gradient: LinearGradient(
//                   colors: [Color(0xFFEAF5FC), Color(0xFFD8E7FA)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 10,
//                     offset: Offset(2, 4),
//                   ),
//                 ],
//               ),
//               padding: const EdgeInsets.all(20),
//               child: Form(
//                 key: _formKey,
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       buildLabel('TO'),
//                       _buildDropdownField(
//                         items: toItems,
//                         value: selectedTo,
//                         hint: 'Select recipient',
//                         onChanged: (val) => setState(() => selectedTo = val),
//                       ),
//                       SizedBox(height: 16),

//                       buildLabel('DATE'),
//                       TextFormField(
//                         controller: dateController,
//                         readOnly: true,
//                         onTap: () => _selectDate(context),
//                         decoration: InputDecoration(
//                           hintText: 'Eg: 25-07-2025',
//                           hintStyle: GoogleFonts.poppins(),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: Colors.grey.shade400),
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           filled: true,
//                           fillColor: Colors.white,
//                         ),
//                       ),
//                       SizedBox(height: 16),

//                       buildLabel('COLLABORATION'),
//                       _buildDropdownField(
//                         items: collaborationItems,
//                         value: selectedCollaboration,
//                         hint: 'Select',
//                         onChanged: (val) =>
//                             setState(() => selectedCollaboration = val),
//                       ),
//                       SizedBox(height: 16),

//                       buildLabel('MODE OF MEET'),
//                       _buildDropdownField(
//                         items: [
//                           {'label': 'Online', 'value': 'Online'},
//                           {'label': 'Offline', 'value': 'Offline'}
//                         ],
//                         value: selectedMode,
//                         hint: 'Select',
//                         onChanged: (val) => setState(() => selectedMode = val),
//                       ),
//                       SizedBox(height: 30),

//                       SizedBox(
//                         width: double.infinity,
//                         height: 50,
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             padding: EdgeInsets.zero,
//                             backgroundColor: Colors.white,
//                             shadowColor: Colors.transparent,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                           onPressed: () {
//                             if (_formKey.currentState!.validate()) {
//                               Navigator.pop(context);
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text(
//                                     'Meetup created successfully!',
//                                     style: TextStyle(
//                                       color: Color(0xFF014576),
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                   backgroundColor: Colors.white,
//                                   behavior: SnackBarBehavior.floating,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                               );
//                             }
//                           },
//                           child: Ink(
//                             decoration: BoxDecoration(
//                               color: Color.fromARGB(170, 141, 188, 222),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Container(
//                               alignment: Alignment.center,
//                               child: Text(
//                                 'Submit',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w600,
//                                   color: Color(0xFF014576),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDropdownField({
//     required List<Map<String, String>> items,
//     required String? value,
//     required String hint,
//     required void Function(String?) onChanged,
//   }) {
//     return DropdownButtonHideUnderline(
//       child: Container(
//         height: 55,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(color: Colors.grey.shade400),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         padding: EdgeInsets.symmetric(horizontal: 12),
//         child: DropdownButtonFormField<String>(
//           padding: EdgeInsets.only(top: 15, right: 10),
//           isExpanded: true,
//           icon: Icon(Icons.arrow_drop_up, color: Colors.black87),
//           dropdownColor: Colors.white,
//           style: GoogleFonts.poppins(color: Colors.black),
//           value: value,
//           hint: Text(hint,
//               style: GoogleFonts.poppins(color: Colors.black54, fontSize: 16)),
//           decoration: InputDecoration.collapsed(hintText: ''),
//           borderRadius: BorderRadius.circular(12),
//           items: items.map((e) {
//             return DropdownMenuItem<String>(
//               value: e['value'],
//               child: Text(e['label']!, style: GoogleFonts.poppins()),
//             );
//           }).toList(),
//           onChanged: onChanged,
//         ),
//       ),
//     );
//   }
// }



