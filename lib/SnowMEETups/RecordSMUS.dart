import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/Data/Repositories/New%20Repositories/Meetup/Smus.dart';
import 'package:snow_app/Data/Repositories/New%20Repositories/repo_allbusniess.dart';
import 'package:snow_app/Data/Repositories/common_repository.dart';
import 'package:snow_app/Data/models/New%20Model/allfetchbusiness.dart';
import 'package:snow_app/core/result.dart';
import 'package:snow_app/SnowBusinessOpporuntines/EnhancedSearchIgloosDialog.dart';

class RecordSMUS extends StatefulWidget {
  const RecordSMUS({Key? key}) : super(key: key);

  @override
  _RecordSMUSState createState() => _RecordSMUSState();
}

class _RecordSMUSState extends State<RecordSMUS>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  TextEditingController _toController = TextEditingController();
  TextEditingController _abstractController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _followupController = TextEditingController();

  DateTime? _date;
  DateTime? _followupDate;
  String? _mode;
  int _collab = 0;

  String? _selectedMemberName;
  String? _selectedMyIglooMember;
  int? _selectedBusinessId;
  String? _selectedUniqueMemberId;

  List<String> _myIglooMembers = [];
  List<BusinessItem> _businessItems = [];
  List<Map<String, dynamic>> _dropdownItems = [];
  FilterData? _currentFilters;
  final List<String> _modes = [
    'Select Mode of Meeting',
    'Online',
    'Offline',
    'Hybrid',
  ];

  bool _isLoading = false;
  bool _isDropdownLoading = true;

  // Animated dots for loading
  late final AnimationController _dotsController;
  late final Animation<int> _dotsAnimation;

  final BusinessRepository businessRepo = BusinessRepository();
  final commonRepository = CommonRepository();

  @override
  void initState() {
    super.initState();

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _dotsAnimation = IntTween(begin: 0, end: 3).animate(_dotsController);

    _fetchMyIglooMembers();
  }

  Future<void> _fetchMyIglooMembers() async {
    print('🎯 RECORDSMUS - _fetchMyIglooMembers called');
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
          _myIglooMembers = result.value
              .map((e) => e.business.name ?? '')
              .toList();

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
            if (_myIglooMembers.where((name) => name == businessName).length >
                1) {
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
        print('✅ Successfully loaded ${_myIglooMembers.length} members');
        print('📋 Member names: $_myIglooMembers');
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
        SnackBar(
          content: Text("Error fetching members: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    _toController.dispose();
    _abstractController.dispose();
    _dateController.dispose();
    _followupController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext ctx, {required bool isFollowUp}) async {
    final picked = await showDatePicker(
      context: ctx,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFollowUp) {
          _followupDate = picked;
          _followupController.text =
              "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
        } else {
          _date = picked;
          _dateController.text =
              "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
        }
      });
    }
  }

  void _showIgloosSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return EnhancedSearchIgloosDialog(
          initialFilters: _currentFilters,
          onFiltersApplied: (FilterData filters) {
            print('🔧 FILTERS APPLIED in RecordSMUS');
            print('📋 Applied Filters: ${filters.toQueryParams()}');
            print('🔍 Has Any Filter: ${filters.hasAnyFilter}');

            setState(() {
              _currentFilters = filters;
              _selectedMemberName = null;
              _selectedMyIglooMember = null;
              _selectedBusinessId = null;
              _selectedUniqueMemberId = null;
            });
            // Refresh the members list with new filters
            _fetchMyIglooMembers();
          },
        );
      },
    );
  }

  Future<void> _submitForm({bool resetAfter = false}) async {
    final bool hasRecipient =
        _toController.text.trim().isNotEmpty ||
        _selectedMemberName != null ||
        _selectedMyIglooMember != null;

    if (!hasRecipient) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select "To" member.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_date == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select Date.')));
      return;
    }

    if (_mode == null || _mode == _modes[0]) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Mode of Meeting.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Determine the business ID to use
      int businessIdToUse = _selectedBusinessId ?? 1;
      String memberName = _toController.text.trim().isNotEmpty
          ? _toController.text.trim()
          : (_selectedMyIglooMember ?? '');

      print('📤 Submitting SMU with:');
      print('   - Member: $memberName');
      print('   - Business ID: $businessIdToUse');
      print('   - Mode: $_mode');

      final body = {
        "to_member": memberName,
        "to_business_id": businessIdToUse,
        "abstract": _abstractController.text.trim(),
        "date":
            "${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}",
        "collab_type": _collab,
        "followup_date": _followupDate != null
            ? "${_followupDate!.year}-${_followupDate!.month.toString().padLeft(2, '0')}-${_followupDate!.day.toString().padLeft(2, '0')}"
            : null,
        "mode": _mode,
      };

      final repo = ReferralsRepositorysums();
      final response = await repo.recordSmus(body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'SMU recorded successfully.'),
          backgroundColor: Colors.green,
        ),
      );

      if (resetAfter) _resetForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    setState(() {
      _toController.clear();
      _abstractController.clear();
      _dateController.clear();
      _followupController.clear();

      _date = null;
      _followupDate = null;
      _mode = null;
      _collab = 0;
      _selectedMemberName = null;
      _selectedMyIglooMember = null;
      _selectedBusinessId = null;
      _selectedUniqueMemberId = null;
      _formKey.currentState?.reset();
    });
  }

  Widget buildLabel(String text, {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
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
            if (required)
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
      hintStyle: GoogleFonts.poppins(fontSize: 13),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
              "RECORD SMU",
              style: GoogleFonts.poppins(
                color: const Color(0xFF014576),
                fontWeight: FontWeight.w600,
                fontSize: 20,
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFFEAF5FC), Color(0xFFD8E7FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
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
                        decoration: _inputDecoration("Enter recipient name"),
                      ),
                      const SizedBox(height: 16),

                      buildLabel(
                        "Select a member from My Igloo",
                        required: false,
                      ),
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

                      // ... rest of your UI (Abstract, Date, Collab Type, etc.) remains unchanged
                      buildLabel("Abstract of SMU"),
                      TextFormField(
                        controller: _abstractController,
                        maxLines: 4,
                        decoration: _inputDecoration(""),
                        validator: (v) =>
                            v == null || v.isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 20),

                      buildLabel("Date"),
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        decoration: _inputDecoration("dd-mm-yyyy").copyWith(
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today_outlined),
                            onPressed: () =>
                                _pickDate(context, isFollowUp: false),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      buildLabel("Collaboration Type", required: false),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          RadioListTile<int>(
                            value: 1,
                            groupValue: _collab,
                            onChanged: (v) => setState(() => _collab = v!),
                            activeColor: const Color(0xFF014576),
                            title: Text(
                              "Business Opportunity Exchanged",
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                          ),
                          RadioListTile<int>(
                            value: 2,
                            groupValue: _collab,
                            onChanged: (v) => setState(() => _collab = v!),
                            activeColor: const Color(0xFF014576),
                            title: Text(
                              "Business Opportunity for Other Member",
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      buildLabel("Next Follow-up SMU Date", required: false),
                      TextFormField(
                        controller: _followupController,
                        readOnly: true,
                        decoration: _inputDecoration("dd-mm-yyyy").copyWith(
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today_outlined),
                            onPressed: () =>
                                _pickDate(context, isFollowUp: true),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      buildLabel("Mode of Meeting"),
                      DropdownButtonFormField<String>(
                        value: _mode ?? _modes[0],
                        items: _modes.map((m) {
                          return DropdownMenuItem<String>(
                            value: m,
                            child: Text(
                              m,
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _mode = v),
                        decoration: _inputDecoration("Select Mode of Meeting"),
                        validator: (v) =>
                            v == null || v == _modes[0] ? "Required" : null,
                      ),
                      const SizedBox(height: 30),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  170,
                                  141,
                                  188,
                                  222,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _isLoading
                                  ? null
                                  : () => _submitForm(resetAfter: false),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
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
                          const SizedBox(width: 14),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF014576),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _isLoading
                                  ? null
                                  : () => _submitForm(resetAfter: true),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "SAVE & NEW",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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
