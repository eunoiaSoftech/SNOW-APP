// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:snow_app/Data/Models/admin_igloo.dart';
// import 'package:snow_app/SnowBusinessOpporuntines/EnhancedSearchIgloosDialog.dart';
// import 'package:snow_app/common api/all_business_api.dart';
// import 'package:snow_app/common api/all_business_directory_model.dart';

// import '../../Data/Repositories/New Repositories/SBOR/sbor_repo.dart';

// class RecordSBOR extends StatefulWidget {
//   const RecordSBOR({Key? key}) : super(key: key);

//   @override
//   _RecordSBORState createState() => _RecordSBORState();
// }

// class _RecordSBORState extends State<RecordSBOR>
//     with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final _amountController = TextEditingController();
//   final _commentsController = TextEditingController();

//   final repository = ReferralsRepositorySbor();
//   List<BusinessDirectoryItem> _businessItems = [];
//   FilterData? _currentFilters;
//   List<Igloo> _igloos = [];
//   bool _isLoading = false;
//   bool _isDropdownLoading = true;

//   int? _selectedBusinessId;
//   String? _selectedBusinessName;

//   late final AnimationController _dotsController;
//   late final Animation<int> _dotsAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _dotsController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 1),
//     )..repeat();

//     _dotsAnimation = IntTween(begin: 0, end: 3).animate(_dotsController);

//     _fetchMembers(); // ONLY THIS
//   }

//   Future<void> _fetchMembers() async {
//     setState(() => _isDropdownLoading = true);

    

//     try {
//       final repo = DirectoryBusinessRepository(); // <<< CORRECT REPO
//       final response = await repo.fetchAllActiveBusinesses();
      

//       setState(() {
//         _businessItems = response.data; // THIS IS List<BusinessDirectoryItem>
//         _isDropdownLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isDropdownLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Failed to fetch businesses: $e"),
//           backgroundColor: Colors.redAccent,
//         ),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _amountController.dispose();
//     _commentsController.dispose();
//     _dotsController.dispose();
//     super.dispose();
//   }

//   void _filterIgloosOffline() {
//     List<Igloo> filtered = _igloos;

//     if (_currentFilters?.businessName != null &&
//         _currentFilters!.businessName!.isNotEmpty) {
//       filtered = filtered
//           .where(
//             (i) => i.name.toLowerCase().contains(
//               _currentFilters!.businessName!.toLowerCase(),
//             ),
//           )
//           .toList();
//     }

//     if (_currentFilters?.country != null &&
//         _currentFilters!.country!.isNotEmpty) {
//       filtered = filtered
//           .where(
//             (i) =>
//                 (i.countryName ?? '').toLowerCase() ==
//                 _currentFilters!.country!.toLowerCase(),
//           )
//           .toList();
//     }

//     if (_currentFilters?.zone != null && _currentFilters!.zone!.isNotEmpty) {
//       filtered = filtered
//           .where(
//             (i) =>
//                 (i.zoneName ?? '').toLowerCase() ==
//                 _currentFilters!.zone!.toLowerCase(),
//           )
//           .toList();
//     }

//     if (_currentFilters?.city != null && _currentFilters!.city!.isNotEmpty) {
//       filtered = filtered
//           .where(
//             (i) =>
//                 (i.cityName ?? '').toLowerCase() ==
//                 _currentFilters!.city!.toLowerCase(),
//           )
//           .toList();
//     }

//     setState(() {
//       _igloos = filtered;
//     });
//   }

//   void _showIgloosSearchDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return EnhancedSearchIgloosDialog(
//           initialFilters: _currentFilters,
//           onFiltersApplied: (FilterData filters) {
//             setState(() {
//               _currentFilters = filters;

//               // RESET selection
//               _selectedBusinessId = null;
//               _selectedBusinessName = null;

//               // APPLY FILTERS ON BUSINESS LIST
//               _applyBusinessFilters(filters);
//             });
//           },
//         );
//       },
//     );
//   }

// void _submitForm() async {
//   final isValid = _formKey.currentState!.validate();

//   if (!isValid) return;

//   setState(() => _isLoading = true);

//   try {
//     // 🔹 FETCH LOGIN DATA
//     final prefs = await SharedPreferences.getInstance();

//     // 🔥 DEBUG PRINTS — ADD THESE
//     print("🟣 Checking login data before submitting SBOR...");
//     print("➡ user_id from prefs: ${prefs.getInt("user_id")}");
//     print("➡ business_id from prefs: ${prefs.getInt("business_id")}");

//     final int? loggedInBusinessId = prefs.getInt("business_id");
//     final int? loggedInUserId = prefs.getInt("user_id");

//     // 🔥 NULL CHECK WITH PRINTS
//     if (loggedInBusinessId == null || loggedInUserId == null) {
//       print("❌ Missing data => user_id: $loggedInUserId, business_id: $loggedInBusinessId");

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Login data missing")),
//       );

//       setState(() => _isLoading = false);
//       return;
//     }

//     // 🔹 CREATE CORRECT REQUEST BODY
//     final request = {
//       "from_business_id": loggedInBusinessId,
//       "giver_user_id": loggedInUserId,
//       "amount": _amountController.text.trim(),
//       "comment": _commentsController.text.trim(),
//     };

//     print("📤 Sending SBOR request: $request"); // DEBUG

//     final response = await repository.createSbor(request);

//     setState(() => _isLoading = false);

//     print("📥 SBOR Response: $response"); // DEBUG

//     if (response['success'] == true) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(response['message'] ?? 'SBOR created successfully!'),
//           backgroundColor: Colors.green,
//         ),
//       );

//       _formKey.currentState?.reset();
//       _amountController.clear();
//       _commentsController.clear();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(response['message'] ?? 'Failed to record SBOR'),
//           backgroundColor: Colors.redAccent,
//         ),
//       );
//     }
//   } catch (e) {
//     print("🔥 Exception during SBOR: $e");

//     setState(() => _isLoading = false);
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Error: $e"), backgroundColor: Colors.redAccent),
//     );
//   }
// }



//   InputDecoration _inputDecoration(String hint) {
//     return InputDecoration(
//       hintText: hint,
//       hintStyle: GoogleFonts.poppins(),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey.shade400),
//       ),
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//       filled: true,
//       fillColor: Colors.white,
//     );
//   }

//   void _applyBusinessFilters(FilterData filters) {
//     // final repo = DirectoryBusinessRepository();

//     // Filter before setting
//     List<BusinessDirectoryItem> filtered = _businessItems;
   


//     if (filters.businessName != null && filters.businessName!.isNotEmpty) {
//       filtered = filtered.where((item) {
//         return item.data.businessName!.toLowerCase().contains(
//           filters.businessName!.toLowerCase(),
//         );
//       }).toList();
//     }

//     if (filters.country != null && filters.country!.isNotEmpty) {
//       filtered = filtered.where((item) {
//         return (item.data.country ?? "").toLowerCase() ==
//             filters.country!.toLowerCase();
//       }).toList();
//     }

//     if (filters.zone != null && filters.zone!.isNotEmpty) {
//       filtered = filtered.where((item) {
//         return (item.data.zone ?? "").toLowerCase() ==
//             filters.zone!.toLowerCase();
//       }).toList();
//     }

//     if (filters.city != null && filters.city!.isNotEmpty) {
//       filtered = filtered.where((item) {
//         return (item.data.city ?? "").toLowerCase() ==
//             filters.city!.toLowerCase();
//       }).toList();
//     }

//     setState(() {
//       _businessItems = filtered;
//     });
//   }

//   Widget _buildTextField(
//     String label,
//     TextEditingController controller,
//     String hint, {
//     TextInputType keyboardType = TextInputType.text,
//     String? Function(String?)? validator,
//     int maxLines = 1,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(bottom: 8.0),
//           child: Text(
//             label,
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: const Color(0xFF014576),
//             ),
//           ),
//         ),
//         TextFormField(
//           controller: controller,
//           maxLines: maxLines,
//           keyboardType: keyboardType,
//           decoration: _inputDecoration(hint),
//           validator:
//               validator ??
//               (value) {
//                 if (value == null || value.isEmpty) return 'Required';
//                 return null;
//               },
//         ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }

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

//         Scaffold(
//           backgroundColor: Colors.transparent,
//           appBar: AppBar(
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             title: Text(
//               "RECORD SBOR",
//               style: GoogleFonts.poppins(
//                 color: const Color(0xFF014576),
//                 fontWeight: FontWeight.w600,
//                 fontSize: 20,
//               ),
//             ),
//             iconTheme: const IconThemeData(color: Color(0xFF014576)),
//             actions: [
//               IconButton(
//                 icon: Icon(
//                   _currentFilters?.hasAnyFilter == true
//                       ? Icons.filter_alt
//                       : Icons.filter_alt_outlined,
//                   color: _currentFilters?.hasAnyFilter == true
//                       ? Colors.orange
//                       : const Color(0xFF014576),
//                 ),
//                 onPressed: _showIgloosSearchDialog,
//               ),
//             ],
//           ),

//           body: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(20),
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFFEAF5FC), Color(0xFFD8E7FA)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 10,
//                     offset: const Offset(2, 4),
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
//                       Padding(
//                         padding: const EdgeInsets.only(bottom: 8.0),
//                         child: Text(
//                           "Select Business",
//                           style: GoogleFonts.poppins(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             color: const Color(0xFF014576),
//                           ),
//                         ),
//                       ),

//                       _isDropdownLoading
//                           ? TextFormField(
//                               enabled: false,
//                               decoration: _inputDecoration("Loading...")
//                                   .copyWith(
//                                     suffix: AnimatedBuilder(
//                                       animation: _dotsAnimation,
//                                       builder: (_, __) {
//                                         String dots =
//                                             '.' * _dotsAnimation.value;
//                                         return Text(dots);
//                                       },
//                                     ),
//                                   ),
//                             )
//                           : DropdownButtonFormField<int>(
//                               isExpanded: true,
//                               value: _selectedBusinessId,
//                               items: _businessItems.map((item) {
//                                 final name =
//                                     item.data.businessName ??
//                                     "Unknown Business";

//                                 return DropdownMenuItem<int>(
//                                   value: item.id,
//                                   child: Text(
//                                     name,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: GoogleFonts.poppins(fontSize: 14),
//                                   ),
//                                 );
//                               }).toList(),
//                               onChanged: (id) {
//                                 setState(() {
//                                   _selectedBusinessId = id;
//                                   if (id != null) {
//                                     final selected = _businessItems.firstWhere(
//                                       (x) => x.id == id,
//                                     );
//                                     _selectedBusinessName =
//                                         selected.data.businessName;
//                                   }
//                                 });
//                               },
//                               decoration: _inputDecoration('Select a business'),
//                               validator: (value) =>
//                                   value == null ? 'Required' : null,
//                             ),

//                       const SizedBox(height: 16),

//                       if (_selectedBusinessName != null)
//                         Text(
//                           'Selected: $_selectedBusinessName',
//                           style: GoogleFonts.poppins(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),

//                       const SizedBox(height: 20),

//                       _buildTextField(
//                         'Amount',
//                         _amountController,
//                         'Enter amount',
//                         keyboardType: TextInputType.number,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Required';
//                           }
//                           if (!RegExp(r"^[0-9]+$").hasMatch(value)) {
//                             return 'Only numbers allowed';
//                           }
//                           return null;
//                         },
//                       ),

//                       Text(
//                         "Comments",
//                         style: GoogleFonts.poppins(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: const Color(0xFF014576),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       TextFormField(
//                         controller: _commentsController,
//                         maxLines: 4,
//                         decoration: _inputDecoration("Write your comments"),
//                       ),

//                       const SizedBox(height: 30),

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
//                           onPressed: _isLoading ? null : _submitForm,
//                           child: Ink(
//                             decoration: BoxDecoration(
//                               color: const Color.fromARGB(170, 141, 188, 222),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Center(
//                               child: _isLoading
//                                   ? const CircularProgressIndicator(
//                                       color: Colors.white,
//                                     )
//                                   : Text(
//                                       'SUBMIT',
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w600,
//                                         color: const Color(0xFF014576),
//                                       ),
//                                     ),
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
// }
