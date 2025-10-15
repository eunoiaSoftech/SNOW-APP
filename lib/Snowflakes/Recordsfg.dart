import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/Data/Repositories/New%20Repositories/repo_allbusniess.dart';
import 'package:snow_app/Data/Repositories/New%20Repositories/sgf/sgf_repo.dart';
import 'package:snow_app/Data/models/New%20Model/allfetchbusiness.dart';
import 'package:snow_app/SnowBusinessOpporuntines/EnhancedSearchIgloosDialog.dart';
import 'package:snow_app/core/result.dart';

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
  bool _isLoading = false;
  bool _isDropdownLoading = true;
  int? _selectedBusinessId;
  String? _selectedUniqueMemberId;

  List<String> _members = [];
  List<BusinessItem> _businessItems = [];
  List<Map<String, dynamic>> _dropdownItems = [];
  FilterData? _currentFilters;

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
    _fetchMembers();
  }

  @override
  void dispose() {
    _toController.dispose();
    _amountController.dispose();
    _commentsController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  Future<void> _fetchMembers() async {
    print('🎯 RECORDSFG - _fetchMembers called');
    print('📋 Current Filters: ${_currentFilters?.toQueryParams()}');
    print('🔍 Has Any Filter: ${_currentFilters?.hasAnyFilter}');

    setState(() => _isDropdownLoading = true);

    try {
      final repo = BusinessRepository();

      // Determine if we should pass showAll based on filters
      bool shouldShowAll =
          _currentFilters == null || !_currentFilters!.hasAnyFilter;

      print('📊 Should Show All: $shouldShowAll');

      final Result<List<BusinessItem>> result = await repo.fetchBusiness(
        page: 1,
        country: _currentFilters?.country ?? '',
        zone: _currentFilters?.zone ?? '',
        city: _currentFilters?.city ?? '',
        search: _currentFilters?.businessName ?? '',
        showAll: shouldShowAll,
      );

      if (result is Ok<List<BusinessItem>>) {
        setState(() {
          _businessItems = result.value;
          _members = result.value.map((e) => e.business.name ?? '').toList();

          // Create dropdown items with unique identifiers to handle duplicate names
          _dropdownItems = result.value.map((item) {
            final businessName = item.business.name ?? 'Unknown Business';
            final businessId = item.id;
            final displayName = item.displayName;
            final contact = item.business.contact ?? '';

            // Create unique identifier combining name and ID
            final uniqueId = '${businessName}_$businessId';

            // Create display text that shows additional info for duplicates
            String displayText = businessName;
            if (_members.where((name) => name == businessName).length > 1) {
              // If there are duplicate names, show additional info
              if (displayName.isNotEmpty && displayName != businessName) {
                displayText = '$businessName ($displayName)';
              } else if (contact.isNotEmpty) {
                displayText = '$businessName ($contact)';
              } else {
                displayText = '$businessName (ID: $businessId)';
              }
            }

            return {
              'uniqueId': uniqueId,
              'businessName': businessName,
              'displayText': displayText,
              'businessId': businessId,
              'businessItem': item,
            };
          }).toList();

          _isDropdownLoading = false;
        });
        print('✅ Successfully loaded ${_members.length} members');
        print('📋 Member names: $_members');
        print('📋 Business items: ${_businessItems.length} items');
        print('📋 Dropdown items: ${_dropdownItems.length} items');
      } else if (result is Err<List<BusinessItem>>) {
        setState(() => _isDropdownLoading = false);
        print('❌ Failed to fetch members: ${result.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to fetch members: ${result.message}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      setState(() => _isDropdownLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.redAccent),
      );
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
              _selectedUniqueMemberId = null;
            });
            // Refresh the members list with new filters
            _fetchMembers();
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

    // Check if a member is selected from dropdown
    if (_selectedMyIglooMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a member from the dropdown"),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ReferralsRepositorySfg();

      // Use selected member name from dropdown or text field
      String memberName = _selectedMyIglooMember ?? _toController.text.trim();

      print('📤 Submitting SFG with:');
      print('   - Member: $memberName');
      print('   - Business ID: ${_selectedBusinessId ?? 0}');

      final response = await repo.recordSfg(
        toMember: memberName,
        giverBusinessId: _selectedBusinessId ?? 0,
        amount: _amountController.text.trim(),
        remarks: _commentsController.text.trim(),
      );

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );

        _formKey.currentState!.reset();
        _toController.clear();
        _amountController.clear();
        _commentsController.clear();
        setState(() {
          _selectedMyIglooMember = null;
          _selectedBusinessId = null;
          _selectedUniqueMemberId = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed: ${response.message}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
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
              "Record SFG",
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
                      buildLabel("To"),
                      TextFormField(
                        controller: _toController,
                        decoration: _inputDecoration("Enter recipient"),
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 16),
                      buildLabel("Select a member from My Igloo"),
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
                                    "Loading" +
                                        "." * _dotsAnimation.value +
                                        " " * (3 - _dotsAnimation.value),
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
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                value: _selectedUniqueMemberId,
                                items: _dropdownItems.map((
                                  Map<String, dynamic> item,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: item['uniqueId'],
                                    child: Text(
                                      item['displayText'],
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newUniqueId) {
                                  debugPrint("newUniqueId ${newUniqueId}");
                                  setState(() {
                                    _selectedUniqueMemberId = newUniqueId;

                                    if (newUniqueId != null) {
                                      // Find the selected dropdown item
                                      final selectedItem = _dropdownItems
                                          .firstWhere(
                                            (item) =>
                                                item['uniqueId'] == newUniqueId,
                                            orElse: () => {},
                                          );

                                      if (selectedItem.isNotEmpty) {
                                        _selectedMyIglooMember =
                                            selectedItem['businessName'];
                                        _selectedBusinessId =
                                            selectedItem['businessId'];

                                        print(
                                          '🎯 Selected Member: ${selectedItem['businessName']}',
                                        );
                                        print(
                                          '🆔 Selected Business ID: ${selectedItem['businessId']}',
                                        );
                                        print(
                                          '🔑 Selected Unique ID: $newUniqueId',
                                        );
                                      }
                                    } else {
                                      _selectedMyIglooMember = null;
                                      _selectedBusinessId = null;
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
