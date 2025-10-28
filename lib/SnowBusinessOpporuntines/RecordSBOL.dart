import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/Data/Repositories/New%20Repositories/SBOG%20REPO/recordSbog.dart';
import 'package:snow_app/Data/models/New%20Model/allfetchbusiness.dart';
import 'package:snow_app/Data/models/New%20Model/sbog_model.dart';
import 'package:snow_app/SnowBusinessOpporuntines/EnhancedSearchIgloosDialog.dart';
import 'package:snow_app/Data/Repositories/New%20Repositories/repo_allbusniess.dart';
import 'package:snow_app/core/result.dart';

class RecordSBOL extends StatefulWidget {
  const RecordSBOL({Key? key}) : super(key: key);

  @override
  _RecordSBOLState createState() => _RecordSBOLState();
}

class _RecordSBOLState extends State<RecordSBOL> with SingleTickerProviderStateMixin {
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
  int _selectedLeadLevel = 0;
  int? _selectedBusinessId;

  List<String> _myIglooMembers = [];
  List<BusinessItem> _businessItems = [];
  FilterData? _currentFilters;

  final List<String> leadLevels = [
    " Member passes a lead to another member on WhatsApp.",
    " Member introduces the other member to the client over a call.",
    " Member not only introduces the client but also gives testimony for the member.",
    " Member introduces the other member to the client personally.",
    " Member sees that the deal is closed between the other member and client.",
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
    setState(() => _isDropdownLoading = true);
    try {
      final repo = BusinessRepository();
      bool shouldShowAll = _currentFilters == null || !_currentFilters!.hasAnyFilter;

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
          _myIglooMembers = result.value.map((e) => e.business.name ?? '').toList();
          _isDropdownLoading = false;
        });
      } else if (result is Err<List<BusinessItem>>) {
        setState(() => _isDropdownLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch members: ${result.message}"), backgroundColor: Colors.redAccent),
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
            setState(() {
              _currentFilters = filters;
              _selectedMemberName = null;
              _selectedMyIglooMember = null;
              _selectedBusinessId = null;
            });
            _fetchMembers();
          },
        );
      },
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedBusinessId == null || _selectedLeadLevel == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields, select a member, and select a lead level.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String memberName = _selectedMyIglooMember ?? '';

      final request = SbogRequest(
        receiverBusinessId: _selectedBusinessId!.toString(),
        toMember: memberName,
        referral: _referralController.text.trim(),
        telephone: _telephoneController.text.trim(),
        email: _emailController.text.trim(),
        level: leadLevels[_selectedLeadLevel - 1],
        comments: _commentsController.text.trim(),
      );

      final response = await repository.recordSbog(request.toJson());

      setState(() => _isLoading = false);

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'SBOL recorded successfully!'), backgroundColor: Colors.green),
        );

        _formKey.currentState?.reset();
        setState(() {
          _selectedMemberName = null;
          _selectedMyIglooMember = null;
          _selectedBusinessId = null;
          _selectedLeadLevel = 0;
          _toController.clear();
          _referralController.clear();
          _telephoneController.clear();
          _emailController.clear();
          _commentsController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to record SBOL'), backgroundColor: Colors.redAccent),
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
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF014576)),
            ),
            TextSpan(
              text: '*',
              style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadLevelStars() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            int starIndex = index + 1;
            return GestureDetector(
              onTap: () => setState(() => _selectedLeadLevel = starIndex),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 11.0),
                child: Icon(
                  Icons.star,
                  size: 36,
                  color: _selectedLeadLevel >= starIndex ? Colors.amber : Colors.grey[300],
                  shadows: _selectedLeadLevel >= starIndex ? [const Shadow(color: Colors.orange, blurRadius: 4)] : [],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
          child: _selectedLeadLevel > 0
              ? Container(
                  key: ValueKey(_selectedLeadLevel),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber[100]?.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    leadLevels[_selectedLeadLevel - 1],
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF014576)),
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
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade400)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {TextInputType keyboardType = TextInputType.text}) {
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
                    colors: [Color(0xAA97DCEB), Color(0xAA5E9BC8), Color(0xAA97DCEB), Color(0xAA70A9EE), Color(0xAA97DCEB)],
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
            title: Text("RECORD SBOL", style: GoogleFonts.poppins(color: const Color(0xFF014576), fontWeight: FontWeight.w600, fontSize: 20)),
            iconTheme: const IconThemeData(color: Color(0xFF014576)),
            actions: [
              IconButton(
                icon: Icon(_currentFilters?.hasAnyFilter == true ? Icons.filter_alt : Icons.filter_alt_outlined,
                    color: _currentFilters?.hasAnyFilter == true ? Colors.orange : const Color(0xFF014576)),
                onPressed: _showIgloosSearchDialog,
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(colors: [Color(0xFFEAF5FC), Color(0xFFD8E7FA)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(2, 4))],
              ),
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField('To', _toController, 'Enter recipient name'),
                      buildLabel('Select a member from My Igloo'),
                      _isDropdownLoading
                          ? TextFormField(
                              enabled: false,
                              decoration: _inputDecoration("Loading...").copyWith(
                                suffix: AnimatedBuilder(
                                  animation: _dotsAnimation,
                                  builder: (context, child) {
                                    String dots = '.' * _dotsAnimation.value;
                                    return Text(dots, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500));
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
                                  final businessName = item.business.name ?? 'Unknown Business';
                                  return DropdownMenuItem<int>(value: item.id, child: Text(businessName, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 14)));
                                }).toList(),
                                onChanged: (int? businessId) {
                                  setState(() {
                                    _selectedBusinessId = businessId;
                                    if (businessId != null) {
                                      final selectedBusiness = _businessItems.firstWhere(
                                        (item) => item.id == businessId,
                                        orElse: () => BusinessItem(
                                          id: 0,
                                          email: '',
                                          fullName: '',
                                          displayName: '',
                                          registeredDate: DateTime.now(),
                                          status: '',
                                          business: BusinessDetails(name: '', contact: '', city: '', zone: '', country: ''),
                                        ),
                                      );
                                      _selectedMyIglooMember = selectedBusiness.business.name;
                                    } else {
                                      _selectedMyIglooMember = null;
                                    }
                                  });
                                },
                                decoration: _inputDecoration('Select a member'),
                                validator: (value) => value == null ? 'Required' : null,
                                menuMaxHeight: 200,
                              ),
                            ),
                      const SizedBox(height: 16),
                      _buildTextField('Referral', _referralController, ''),
                      _buildTextField('Telephone', _telephoneController, '', keyboardType: TextInputType.phone),
                      _buildTextField('Email', _emailController, ''),
                      buildLabel('Level of Lead'),
                      _buildLeadLevelStars(),
                      const SizedBox(height: 16),
                      buildLabel('Comments'),
                      TextFormField(controller: _commentsController, maxLines: 5, decoration: _inputDecoration('Write your comments')),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _isLoading ? null : _submitForm,
                          child: Ink(
                            decoration: BoxDecoration(color: const Color.fromARGB(170, 141, 188, 222), borderRadius: BorderRadius.circular(10)),
                            child: Container(
                              alignment: Alignment.center,
                              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('SUBMIT', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF014576))),
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
