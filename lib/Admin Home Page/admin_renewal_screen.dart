// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class AdminRenewalScreen extends StatefulWidget {
//   const AdminRenewalScreen({super.key});

//   @override
//   State<AdminRenewalScreen> createState() => _AdminRenewalScreenState();
// }

// class _AdminRenewalScreenState extends State<AdminRenewalScreen> {
//   DateTime? joiningDate;
//   int duration = 1;
//   DateTime? dueDate;

//   void calculateDueDate() {
//     if (joiningDate != null) {
//       setState(() {
//         dueDate = DateTime(
//           joiningDate!.year + duration,
//           joiningDate!.month,
//           joiningDate!.day,
//         );
//       });
//     }
//   }

//   Future<void> pickDate() async {
//     DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );

//     if (picked != null) {
//       setState(() {
//         joiningDate = picked;
//       });
//       calculateDueDate();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Membership Renewal",
//           style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [

//             /// Date of Joining
//             GestureDetector(
//               onTap: pickDate,
//               child: Container(
//                 padding: const EdgeInsets.all(15),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey.shade300),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       joiningDate == null
//                           ? "Select Date of Joining"
//                           : "${joiningDate!.day}/${joiningDate!.month}/${joiningDate!.year}",
//                       style: GoogleFonts.poppins(),
//                     ),
//                     const Icon(Icons.calendar_today),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),

//             /// Duration Dropdown
//             DropdownButtonFormField<int>(
//               value: duration,
//               decoration: const InputDecoration(
//                 labelText: "Membership Duration (Years)",
//                 border: OutlineInputBorder(),
//               ),
//               items: [1, 2, 3, 4, 5]
//                   .map((e) => DropdownMenuItem(
//                         value: e,
//                         child: Text("$e Year"),
//                       ))
//                   .toList(),
//               onChanged: (val) {
//                 setState(() {
//                   duration = val!;
//                 });
//                 calculateDueDate();
//               },
//             ),

//             const SizedBox(height: 30),

//             /// Due Date Display
//             if (dueDate != null)
//               Container(
//                 padding: const EdgeInsets.all(15),
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   "Due Date: ${dueDate!.day}/${dueDate!.month}/${dueDate!.year}",
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }