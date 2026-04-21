import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/Data/Models/profile_overview.dart';
import 'package:snow_app/Data/Repositories/New%20Repositories/repo_allbusniess.dart';
import 'package:snow_app/Data/Repositories/New%20Repositories/sgf/sgf_repo.dart';
import 'package:snow_app/Data/models/New%20Model/allfetchbusiness.dart';
import 'package:snow_app/SnowBusinessOpporuntines/EnhancedSearchIgloosDialog.dart';
import 'package:snow_app/core/result.dart';
import 'package:snow_app/data/repositories/profile_repository.dart';

class SnowflakesRecordSFG extends StatefulWidget {
  const SnowflakesRecordSFG({Key? key}) : super(key: key);

  @override
  _SnowflakesRecordSFGState createState() => _SnowflakesRecordSFGState();
}

class _SnowflakesRecordSFGState extends State<SnowflakesRecordSFG>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _toController = TextEditingController();
  final _amountController = TextEditingController();
  final _commentsController = TextEditingController();

  String? _selectedMyIglooMember;
  int? _selectedBusinessId;
  bool _isLoading = false;
  bool _isDropdownLoading = true;
  int? myCityId;
  bool isMyCitySelected = true;

  List<String> _members = [];
  // List<BusinessDirectoryItem> _businessItems = [];
  List<BusinessItem> _businessItems = [];
  String? _selectedBusinessType; // new or repeat

  FilterData? _currentFilters;

  late final AnimationController _dotsController;
  late final Animation<int> _dotsAnimation;
  static const _businessTypeOptions = [
    {'label': 'New Business', 'value': 'new business'},
    {'label': 'Repeat Business', 'value': 'repeat'},
  ];

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

  @override
  void dispose() {
    _toController.dispose();
    _amountController.dispose();
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

  void _showIgloosSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return EnhancedSearchIgloosDialog(
          initialFilters: _currentFilters,
          onFiltersApplied: (FilterData filters) {
            print('🔧 FILTERS APPLIED in Recordsfg');
            print('📋 Applied Filters: ${filters.toQueryParams()}');
            print('🔍 Has Any Filter: ${filters.hasAnyFilter}');

            setState(() {
              _currentFilters = filters;
              _selectedMyIglooMember = null;
              _selectedBusinessId = null;
            });
            // Refresh the members list with new filters
            _fetchMyIglooMembers();
          },
        );
      },
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    // Ensure user selects a business
    if (_selectedBusinessId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a member from the dropdown"),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = SfgRepository();

      print("📤 Creating SFG...");
      print("   opponent_user_id: $_selectedBusinessId");
      print("   amount: ${_amountController.text.trim()}");
      print("   comment: ${_commentsController.text.trim()}");

      final response = await repo.createSfg(
        opponentUserId: _selectedBusinessId!,
        amount: _amountController.text.trim(),
        comment: _commentsController.text.trim(),
        type: _selectedBusinessType!, // 👈 ADD THIS
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response["message"] ?? "Created successfully",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );

      _formKey.currentState!.reset();
      _amountController.clear();
      _commentsController.clear();
      setState(() {
        _selectedBusinessId = null;
        _selectedMyIglooMember = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset("assets/bghome.jpg", fit: BoxFit.cover),
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
              "Record Business Closed",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: const Color(0xFF014576),
              ),
            ),
            iconTheme: const IconThemeData(color: Color(0xFF014576)),
            actions: [
              IconButton(
                icon: Icon(
                  _currentFilters?.hasAnyFilter == true
                      ? Icons.filter_alt
                      : Icons.filter_alt_outlined,
                  color: _currentFilters?.hasAnyFilter == true
                      ? Colors.orange
                      : const Color(0xFF014576),
                ),
                onPressed: _showIgloosSearchDialog,
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
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
                      // buildLabel("To"),
                      // TextFormField(
                      //   controller: _toController,
                      //   decoration: _inputDecoration("Enter recipient"),
                      //   validator: (v) => v!.isEmpty ? "Required" : null,
                      // ),
                      // const SizedBox(height: 16),
                      buildLabel("Select a member from My Igloo"),
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
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              child: AnimatedBuilder(
                                animation: _dotsAnimation,
                                builder: (context, child) {
                                  return Text(
                                    "Loading${"." * _dotsAnimation.value}${" " * (3 - _dotsAnimation.value)}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  );
                                },
                              ),
                            )
                          : SizedBox(
                              width: double.infinity,
                              child: DropdownButtonFormField<int>(
                                isExpanded: true,
                                value: _selectedBusinessId,
                                items: _businessItems.map((item) {
                                  final name =
                                      "${item.displayName} - ${item.business.category}";

                                  return DropdownMenuItem<int>(
                                    value: item.id, // THIS IS to_business_id 👈
                                    child: Text(
                                      name,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (int? id) {
                                  setState(() {
                                    _selectedBusinessId = id;

                                    if (id != null) {
                                      final selected = _businessItems
                                          .firstWhere((x) => x.id == id);
                                      _selectedMyIglooMember =
                                          selected.business.name;
                                    } else {
                                      _selectedMyIglooMember = null;
                                    }
                                  });
                                },
                                decoration: _inputDecoration('Select a member'),
                                validator: (value) =>
                                    value == null ? 'Required' : null,
                                menuMaxHeight: 200,
                              ),
                            ),

                      const SizedBox(height: 16),
                      buildLabel("Snowflakes Amount"),

                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration("Enter local currency"),
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 16),

                      buildLabel("Business Type"),
                      const SizedBox(height: 8),

                      DropdownButtonFormField<String>(
                        value: _selectedBusinessType,
                        items: _businessTypeOptions.map((item) {
                          return DropdownMenuItem<String>(
                            value: item['value'],
                            child: Text(item['label']!),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedBusinessType = val;
                          });
                        },
                        decoration: _inputDecoration("Select business type"),
                        validator: (val) => val == null ? "Required" : null,
                      ),

                      const SizedBox(height: 16),
                      buildLabel("Comments"),
                      TextFormField(
                        controller: _commentsController,
                        maxLines: 4,
                        decoration: _inputDecoration("Write your comments"),
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.blue,
                                )
                              : Text(
                                  "SUBMIT",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF014576),
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
