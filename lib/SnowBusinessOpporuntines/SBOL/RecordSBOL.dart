import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/SnowBusinessOpporuntines/EnhancedSearchIgloosDialog.dart';
import 'package:snow_app/common%20api/all_business_directory_model.dart';
import '../../Data/Repositories/New Repositories/SBOL REPO/sbol_repo.dart';
import '../../Data/models/New Model/SBOL MODEL/sbol_model.dart';
import 'package:snow_app/Data/Models/admin_igloo.dart';

import '../../common api/all_business_api.dart';

class RecordSBOL extends StatefulWidget {
  const RecordSBOL({Key? key}) : super(key: key);

  @override
  _RecordSBOLState createState() => _RecordSBOLState();
}

class _RecordSBOLState extends State<RecordSBOL>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _referralController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _commentsController = TextEditingController();
  final _toController = TextEditingController();

  final repository = ReferralsRepositorySbol();

  bool _isLoading = false;
  bool _isDropdownLoading = true;

  String? _selectedMyIglooMember;
  int _selectedLeadLevel = 0;
  int? _selectedBusinessId;

  List<BusinessDirectoryItem> _businessItems = [];
  FilterData? _currentFilters;
  List<Igloo> _igloos = [];

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
    final repo = DirectoryBusinessRepository();   // <<< CORRECT REPO
    final response = await repo.fetchAllActiveBusinesses();

    setState(() {
      _businessItems = response.data;   // THIS IS List<BusinessDirectoryItem>
      _isDropdownLoading = false;
    });

  } catch (e) {
    setState(() => _isDropdownLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Failed to fetch businesses: $e"),
        backgroundColor: Colors.redAccent,
      ),
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
              _selectedMyIglooMember = null;
              _selectedBusinessId = null;
              _selectedBusinessId = null;
              _fetchMembers();
              _filterIgloosOffline();
            });
          },
        );
      },
    );
  }

  void _filterIgloosOffline() {
    List<Igloo> filtered = _igloos;

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

    if (_currentFilters?.zone != null && _currentFilters!.zone!.isNotEmpty) {
      filtered = filtered
          .where(
            (i) =>
                (i.zoneName ?? '').toLowerCase() ==
                _currentFilters!.zone!.toLowerCase(),
          )
          .toList();
    }

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
    if (!_formKey.currentState!.validate() ||
        _selectedBusinessId == null ||
        _selectedLeadLevel == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all fields, select a member, and select a lead level.',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {

      final request = SbolRequest(
        toBusinessId: _selectedBusinessId!.toString(),
        referral: _referralController.text.trim(),
        telephone: _telephoneController.text.trim(),
        email: _emailController.text.trim(),
        level: _selectedLeadLevel,
        comment: _commentsController.text.trim(),
      );

      final response = await repository.recordSbol(request.toJson());

      setState(() => _isLoading = false);

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'SBOL recorded successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        _formKey.currentState?.reset();
        setState(() {
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
          SnackBar(
            content: Text(response['message'] ?? 'Failed to record SBOL'),
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
                  color: _selectedLeadLevel >= starIndex
                      ? Colors.amber
                      : Colors.grey[300],
                  shadows: _selectedLeadLevel >= starIndex
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
          child: _selectedLeadLevel > 0
              ? Container(
                  key: ValueKey(_selectedLeadLevel),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber[100]?.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    leadLevels[_selectedLeadLevel - 1],
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
              "RECORD SBOL",
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
                                items: _businessItems.map((item) {
                                  final name =
                                      item.data.businessName ??
                                      "Unknown Business";

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
                                          selected.data.businessName;
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
                      _buildTextField('Referral', _referralController, ''),
                      _buildTextField(
                        'Telephone',
                        _telephoneController,
                        '',
                        keyboardType: TextInputType.phone,
                      ),
                      _buildTextField('Email', _emailController, ''),
                      buildLabel('Level of Lead'),
                      _buildLeadLevelStars(),
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
