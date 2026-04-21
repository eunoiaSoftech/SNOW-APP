import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/Data/Models/admin_igloo.dart';
import 'package:snow_app/Data/Models/profile_overview.dart';
import 'package:snow_app/Data/Repositories/New%20Repositories/SBOG%20REPO/recordSbog.dart';
import 'package:snow_app/Data/Repositories/New%20Repositories/repo_allbusniess.dart';
import 'package:snow_app/Data/models/New%20Model/allfetchbusiness.dart';

import 'package:snow_app/SnowBusinessOpporuntines/EnhancedSearchIgloosDialog.dart';
import 'package:snow_app/common%20api/all_business_api.dart';
import 'package:snow_app/common%20api/all_business_directory_model.dart';
import 'package:snow_app/core/result.dart';
import 'package:snow_app/data/repositories/profile_repository.dart';
import 'package:snow_app/home/MemberDropdown.dart';

class RecordSBOG extends StatefulWidget {
  const RecordSBOG({Key? key}) : super(key: key);

  @override
  _RecordSBOGState createState() => _RecordSBOGState();
}

class _RecordSBOGState extends State<RecordSBOG>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _referralController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _commentsController = TextEditingController();
  final _toController = TextEditingController();

  final repository = ReferralsRepositorySbog();

  bool _isLoading = false;
  bool _isDropdownLoading = true;
  List<BusinessItem> _businessItems = [];

  String? _selectedMyIglooMember;
  int? _selectedBusinessId;
  List<Igloo> _igloos = [];
  FilterData? _currentFilters;
  int? myCityId;
  bool isMyCitySelected = true;

  late final AnimationController _dotsController;
  late final Animation<int> _dotsAnimation;

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _dotsAnimation = IntTween(begin: 0, end: 3).animate(_dotsController);
    _initData(); // 🔥 ADD THIS
  }

  Future<void> _fetchMyIglooMembers() async {
    setState(() => _isDropdownLoading = true);

    try {
      final repo = BusinessRepository();

      bool shouldShowAll = !isMyCitySelected;

      final result = await repo.fetchBusiness(
        page: 1,
        country: _currentFilters?.countryId ?? '',
        zone: _currentFilters?.zoneId ?? '',
        city: isMyCitySelected
            ? myCityId?.toString() ?? ''
            : (_currentFilters?.cityId ?? ''),
        search: _currentFilters?.businessName ?? '',
        showAll: shouldShowAll,
      );

      if (result is Ok<List<BusinessItem>>) {
        setState(() {
          _businessItems = result.value;
          _isDropdownLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isDropdownLoading = false);
    }
  }

  @override
  void dispose() {
    _referralController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _commentsController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  int? getMyCityId(ProfileOverview profile) {
    try {
      final active = profile.userTypes.firstWhere((e) => e.status == "ACTIVE");

      return active.data['city'] != null
          ? int.tryParse(active.data['city'].toString())
          : null;
    } catch (e) {
      return null;
    }
  }

  // @override
  Future<void> _initData() async {
    final profileRepo = ProfileRepository();
    final res = await profileRepo.fetchProfile();

    if (res is Ok<ProfileOverview>) {
      myCityId = getMyCityId(res.value);
    }

    await _fetchMyIglooMembers();
  }

  void _showIgloosSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return EnhancedSearchIgloosDialog(
          initialFilters: _currentFilters,
          onFiltersApplied: (FilterData filters) {
            print('🔧 FILTERS APPLIED in RecordSBOG');
            print('📋 Applied Filters: ${filters.toQueryParams()}');
            print('🔍 Has Any Filter: ${filters.hasAnyFilter}');

            setState(() {
              _currentFilters = filters;
              _selectedMyIglooMember = null;
            });
            // Refresh the members list with new filters
            _fetchMyIglooMembers();
            _filterIgloosOffline();
          },
        );
      },
    );
  }

  void _filterIgloosOffline() {
    List<Igloo> filtered = _igloos;

    // BUSINESS NAME FILTER (matches igloo.name)
    if (_currentFilters?.businessName != null &&
        _currentFilters!.businessName!.isNotEmpty) {
      filtered = filtered
          .where(
            (i) => i.name.toLowerCase().contains(
              _currentFilters!.businessName!.toLowerCase(),
            ),
          )
          .toList();
    }

    // COUNTRY FILTER (correct field: countryName)
    if (_currentFilters?.country != null &&
        _currentFilters!.country!.isNotEmpty) {
      filtered = filtered
          .where(
            (i) =>
                (i.countryName ?? '').toLowerCase() ==
                _currentFilters!.country!.toLowerCase(),
          )
          .toList();
    }

    // ZONE FILTER (correct field: zoneName)
    if (_currentFilters?.zone != null && _currentFilters!.zone!.isNotEmpty) {
      filtered = filtered
          .where(
            (i) =>
                (i.zoneName ?? '').toLowerCase() ==
                _currentFilters!.zone!.toLowerCase(),
          )
          .toList();
    }

    // CITY FILTER (correct field: cityName)
    if (_currentFilters?.city != null && _currentFilters!.city!.isNotEmpty) {
      filtered = filtered
          .where(
            (i) =>
                (i.cityName ?? '').toLowerCase() ==
                _currentFilters!.city!.toLowerCase(),
          )
          .toList();
    }

    setState(() {
      _igloos = filtered;
    });
  }

  void _submitForm() async {
    // Trigger red validation errors on fields
    final isValid = _formKey.currentState!.validate();

    // Check dropdown
    if (_selectedBusinessId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a member from My Business'),
        ),
      );
      return;
    }

    if (!isValid) return;

    setState(() => _isLoading = true);

    try {
      final request = {
        "to_business_id": _selectedBusinessId,
        "give": _referralController.text.trim(),
        "telephone": _telephoneController.text.trim(),
        "email": _emailController.text.trim(),
        "comment": _commentsController.text.trim(),
      };

      final response = await repository.recordSbog(request);

      setState(() => _isLoading = false);

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'SBOG recorded successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset all values
        _formKey.currentState?.reset();
        setState(() {
          _selectedMyIglooMember = null;
          _toController.clear();
          _referralController.clear();
          _telephoneController.clear();
          _emailController.clear();
          _commentsController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to record SBOG'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    }
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
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel(label),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: _inputDecoration(hint),
          validator:
              validator ??
              (value) {
                if (value == null || value.isEmpty) return 'Required';
                return null;
              },
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
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: _showIgloosSearchDialog,
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: _currentFilters?.hasAnyFilter == true
                          ? const Color(0xFF014576).withOpacity(0.12)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: _currentFilters?.hasAnyFilter == true
                            ? const Color(0xFF014576)
                            : const Color(0xFF014576).withOpacity(0.4),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Icon(
                              Icons.filter_alt,
                              size: 20,
                              color: const Color(0xFF014576),
                            ),

                            /// 🔵 Active dot
                            if (_currentFilters?.hasAnyFilter == true)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF014576),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 6),

                        /// 🔥 CLEAR LABEL
                        Text(
                          "Igloo Filter",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF014576),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                      _buildTextField(
                        'To',
                        _toController,
                        'Enter recipient name',
                      ),

                      buildLabel('Select a member from My Business'),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text("My Igloo"),
                            selected: isMyCitySelected,
                            onSelected: (val) {
                              setState(() {
                                isMyCitySelected = true;
                                _selectedBusinessId = null;
                                _selectedMyIglooMember = null;
                              });
                              _fetchMyIglooMembers(); // 🔥 reload data
                            },
                            selectedColor: const Color(0xFF5E9BC8),
                            labelStyle: TextStyle(
                              color: isMyCitySelected
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          const SizedBox(width: 10),
                          ChoiceChip(
                            label: const Text("Whole Platform"),
                            selected: !isMyCitySelected,
                            onSelected: (val) {
                              setState(() {
                                isMyCitySelected = false;
                                _selectedBusinessId = null;
                                _selectedMyIglooMember = null;
                              });
                              _fetchMyIglooMembers(); // 🔥 reload data
                            },
                            selectedColor: const Color(0xFF5E9BC8),
                            labelStyle: TextStyle(
                              color: !isMyCitySelected
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _isDropdownLoading
                          ? TextFormField(
                              enabled: false,
                              decoration: _inputDecoration("Loading...")
                                  .copyWith(
                                    suffix: AnimatedBuilder(
                                      animation: _dotsAnimation,
                                      builder: (context, child) {
                                        String dots =
                                            '.' * _dotsAnimation.value;
                                        return Text(
                                          dots,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                            )
                              : MemberDropdown(
                              items: _businessItems,
                              selectedId: _selectedBusinessId,
                              onSelected: (item) {
                                setState(() {
                                  _selectedBusinessId = item.id;
                                  _selectedMyIglooMember = item.business.name;
                                });
                              },
                            ),
                          // : SizedBox(
                          //     width: double.infinity,
                          //     child: SizedBox(
                          //       width: double.infinity,
                          //       child: DropdownButtonFormField<int>(
                          //         isExpanded: true,
                          //         value: _selectedBusinessId,
                          //         items: _businessItems.map((item) {
                          //           final name =
                          //               "${item.displayName} - ${item.business.category}";

                          //           return DropdownMenuItem<int>(
                          //             value:
                          //                 item.id, // THIS IS to_business_id 👈
                          //             child: Text(
                          //               name,
                          //               overflow: TextOverflow.ellipsis,
                          //               style: GoogleFonts.poppins(
                          //                 fontSize: 14,
                          //               ),
                          //             ),
                          //           );
                          //         }).toList(),
                          //         onChanged: (int? id) {
                          //           setState(() {
                          //             _selectedBusinessId = id;

                          //             if (id != null) {
                          //               final selected = _businessItems
                          //                   .firstWhere((x) => x.id == id);
                          //               _selectedMyIglooMember =
                          //                   selected.business.name;
                          //             } else {
                          //               _selectedMyIglooMember = null;
                          //             }
                          //           });
                          //         },
                          //         decoration: _inputDecoration(
                          //           'Select a member',
                          //         ),
                          //         validator: (value) =>
                          //             value == null ? 'Required' : null,
                          //         menuMaxHeight: 200,
                          //       ),
                          //     ),
                          //   ),




                      const SizedBox(height: 16),

                      if (_selectedMyIglooMember != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            'Selected: $_selectedMyIglooMember',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      _buildTextField('Give', _referralController, ''),
                      _buildTextField(
                        'Telephone',
                        _telephoneController,
                        '',
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                            return 'Enter a valid 10-digit number';
                          }
                          return null;
                        },
                      ),

                      _buildTextField(
                        'Email',
                        _emailController,
                        '',
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (!RegExp(
                            r'^[\w\-\.]+@([\w\-]+\.)+[\w]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
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
