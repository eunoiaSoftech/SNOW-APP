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

  List<String> _myIglooMembers = [];
  List<BusinessItem> _businessItems = [];
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

          _isDropdownLoading = false;
        });
        print('✅ Successfully loaded ${_myIglooMembers.length} members');
        print('📋 Member names: $_myIglooMembers');
        print('📋 Business items: ${_businessItems.length} items');
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
        _selectedBusinessId == null ||
        _selectedConnectLevel == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all fields, select a member, and select a star rating.',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Use selected member name and business ID
      String memberName = _selectedMyIglooMember ?? '';

      print('📤 Submitting SBOG with:');
      print('   - Member: $memberName');
      print('   - Business ID: $_selectedBusinessId');

      final request = SbogRequest(
        receiverBusinessId: _selectedBusinessId!.toString(),
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
          _selectedBusinessId = null;
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
                              child: DropdownButtonFormField<int>(
                                isExpanded: true,
                                value: _selectedBusinessId,
                                items: _businessItems.map((BusinessItem item) {
                                  final businessName =
                                      item.business.name ?? 'Unknown Business';
                                  return DropdownMenuItem<int>(
                                    value: item.id,
                                    child: Text(
                                      businessName,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (int? businessId) {
                                  debugPrint(
                                    "Selected business ID: $businessId",
                                  );
                                  setState(() {
                                    _selectedBusinessId = businessId;
                                    if (businessId != null) {
                                      final selectedBusiness = _businessItems
                                          .firstWhere(
                                            (item) => item.id == businessId,
                                            orElse: () => BusinessItem(
                                              id: 0,
                                              email: '',
                                              fullName: '',
                                              displayName: '',
                                              registeredDate: DateTime.now(),
                                              status: '',
                                              business: BusinessDetails(
                                                name: '',
                                                contact: '',
                                                city: '',
                                                zone: '',
                                                country: '',
                                              ),
                                            ),
                                          );
                                      _selectedMyIglooMember =
                                          selectedBusiness.business.name;

                                      print(
                                        '🎯 Selected Member: ${selectedBusiness.business.name}',
                                      );
                                      print(
                                        '🎯 Selected Business ID: $businessId',
                                      );
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
