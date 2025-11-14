// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:snow_app/Data/Repositories/New%20Repositories/EXTRA%20FEATURE/traning_reg.dart';

// class TrainingRegisterForm extends StatefulWidget {
//   final int trainingId;
//   final String title;
//   final String date;

//   const TrainingRegisterForm({
//     super.key,
//     required this.trainingId,
//     required this.title,
//     required this.date,
//   });

//   @override
//   State<TrainingRegisterForm> createState() => _TrainingRegisterFormState();
// }

// class _TrainingRegisterFormState extends State<TrainingRegisterForm> {
//   final repo = TrainingRepositoryNew();
//   bool isLoading = false;

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
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
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         Scaffold(
//           backgroundColor: Colors.transparent,
//           appBar: AppBar(
//             elevation: 0,
//             backgroundColor: Colors.transparent,
//             iconTheme: const IconThemeData(color: Color(0xFF014576)),
//             title: Text(
//               "REGISTER",
//               style: GoogleFonts.poppins(
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF014576),
//               ),
//             ),
//           ),

//           body: Center(
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(25),
//               child: BackdropFilter(
//                 filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
//                 child: Container(
//                   margin:
//                       const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
//                   padding: const EdgeInsets.all(24),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(25),
//                     gradient: LinearGradient(
//                       colors: [
//                         Color.fromARGB(255, 204, 234, 249),
//                         Color(0xFF70a1ff),
//                         Color.fromARGB(255, 82, 190, 237),
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         // ignore: deprecated_member_use
//                         color: Colors.blue.shade200.withOpacity(0.4),
//                         blurRadius: 20,
//                         offset: const Offset(0, 8),
//                       )
//                     ],
//                   ),

//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         "Confirm Your Registration",
//                         style: GoogleFonts.poppins(
//                           color: Colors.white,
//                           fontSize: 22,
//                           fontWeight: FontWeight.w700,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),

//                       const SizedBox(height: 20),

//                       _infoTile("Training", widget.title),
//                       _infoTile("Date", widget.date),
//                       _infoTile("Training ID", widget.trainingId.toString()),

//                       const SizedBox(height: 25),

//                       isLoading
//                           ? const CircularProgressIndicator(color: Colors.white)
//                           : ElevatedButton(
//                               onPressed: _registerTraining,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.white,
//                                 minimumSize: const Size(double.infinity, 55),
//                                 elevation: 6,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(15),
//                                 ),
//                               ),
//                               child: Text(
//                                 "Register Now",
//                                 style: TextStyle(
//                                   color: Color(0xFF014576),
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         )
//       ],
//     );
//   }

//   Widget _infoTile(String label, String value) {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
//       decoration: BoxDecoration(
//         color: Colors.white24,
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: Colors.white54),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label,
//               style: GoogleFonts.poppins(
//                 fontSize: 14,
//                 color: Colors.white70,
//               )),
//           Text(value,
//               style: GoogleFonts.poppins(
//                 fontSize: 15,
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//               )),
//         ],
//       ),
//     );
//   }

//   Future<void> _registerTraining() async {
//     setState(() => isLoading = true);

//     final res = await repo.registerForTraining(widget.trainingId);

//     setState(() => isLoading = false);

//     if (res["success"] == true) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Registered successfully!"),
//           backgroundColor: Colors.green,
//         ),
//       );
//       Navigator.pop(context);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Failed: ${res['message'] ?? 'Unknown error'}"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
// }
