import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/Data/Repositories/New%20Repositories/SBOG%20REPO/recordSbog.dart';
import 'package:snow_app/Data/models/New%20Model/allfetchbusiness.dart';
import 'package:snow_app/Data/models/New%20Model/sbog_model.dart';
import 'package:snow_app/SnowBusinessOpporuntines/EnhancedSearchIgloosDialog.dart';
import 'package:snow_app/Data/Repositories/New%20Repositories/repo_allbusniess.dart';
import 'package:snow_app/core/result.dart';

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

  String? _selectedMemberName;
  String? _selectedMyIglooMember;
  int _selectedConnectLevel = 0;
  int? _selectedBusinessId;
  String? _selectedUniqueMemberId;

  List<String> _myIglooMembers = [];
  List<BusinessItem> _businessItems = [];
  List<Map<String, dynamic>> _dropdownItems = [];
  FilterData? _currentFilters;

  final List<String> levelWords = [
    "Very Poor",
    "Poor",
    "Average",
    "Good",
    "Excellent",
  ];

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

  Future<void> _fetchMembers() async {
    print('🎯 RECORDSBOG - _fetchMembers called');
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
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.redAccent),
      );
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
              _selectedMemberName = null;
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
    if (!_formKey.currentState!.validate() ||
        (_selectedMemberName == null && _selectedMyIglooMember == null) ||
        _selectedConnectLevel == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select a star rating.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Determine the business ID to use
      int businessIdToUse = _selectedBusinessId ?? 123;
      String memberName = _selectedMyIglooMember ?? _selectedMemberName!;

      print('📤 Submitting SBOG with:');
      print('   - Member: $memberName');
      print('   - Business ID: $businessIdToUse');

      final request = SbogRequest(
        receiverBusinessId: businessIdToUse.toString(),
        // to: _toController.text.trim(),
        toMember: memberName,
        referral: _referralController.text.trim(),
        telephone: _telephoneController.text.trim(),
        email: _emailController.text.trim(),
        level: levelWords[_selectedConnectLevel - 1],
        comments: _commentsController.text.trim(),
      );

      final response = await repository.recordSbog(request.toJson());

      setState(() => _isLoading = false);

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'SBOG recorded successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset everything
        _formKey.currentState?.reset();
        setState(() {
          _selectedMemberName = null;
          _selectedMyIglooMember = null;
          _selectedConnectLevel = 0;
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

  Widget _buildConnectLevelStars() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            int starIndex = index + 1;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedConnectLevel = starIndex;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 11.0),
                child: Icon(
                  Icons.star,
                  size: 36,
                  color: _selectedConnectLevel >= starIndex
                      ? Colors.amber
                      : Colors.grey[300],
                  shadows: _selectedConnectLevel >= starIndex
                      ? [const Shadow(color: Colors.orange, blurRadius: 4)]
                      : [],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: _selectedConnectLevel > 0
              ? Container(
                  key: ValueKey(_selectedConnectLevel),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber[100]?.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    levelWords[_selectedConnectLevel - 1],
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF014576),
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel(label),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: _inputDecoration(hint),
          validator: (value) => value!.isEmpty ? 'Required' : null,
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

                      buildLabel('Select a member from My Igloo'),
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
                                isExpanded: true, // 👈 VERY IMPORTANT
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

                      if (_selectedMemberName != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            'Selected: $_selectedMemberName',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      _buildTextField('Referral', _referralController, ''),
                      _buildTextField(
                        'Telephone',
                        _telephoneController,
                        '',
                        keyboardType: TextInputType.phone,
                      ),
                      _buildTextField('Email', _emailController, ''),
                      buildLabel('Level of Connect'),
                      _buildConnectLevelStars(),
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
