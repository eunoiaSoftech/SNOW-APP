import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/Data/Repositories/New%20Repositories/Meetup/Smus.dart';
import 'package:snow_app/Data/Repositories/referrals_repository.dart';
import 'package:snow_app/Data/Repositories/common_repository.dart';
import 'package:snow_app/SnowBusinessOpporuntines/_SearchIgloosDialog.dart';

import '../core/api_client.dart';

class RecordSMUS extends StatefulWidget {
  const RecordSMUS({Key? key}) : super(key: key);

  @override
  _RecordSMUSState createState() => _RecordSMUSState();
}

class _RecordSMUSState extends State<RecordSMUS> {
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

  final List<String> _myIglooMembers = ['Member A', 'Member B', 'Member C'];
  final List<String> _modes = [
    'Select Mode of Meeting',
    'Online',
    'Offline',
    'Hybrid',
  ];

  bool _isLoading = false;

  final repository = ReferralsRepository(ApiClient.create());
  final commonRepository = CommonRepository();

  @override
  void dispose() {
    _toController.dispose();
    _abstractController.dispose();
    _dateController.dispose();
    _followupController.dispose();
    super.dispose();
  }

  // ---------------- UI helpers ----------------
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
        return SearchIgloosDialog(
          onMemberSelected: (memberName) {
            setState(() {
              _selectedMemberName = memberName;
              _selectedMyIglooMember = null;
              _toController.text = memberName;
            });
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select Date.')),
    );
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
    final body = {
      "to_member": _toController.text.trim(),
      "to_business_id": 1,
      "abstract": _abstractController.text.trim(),
      "date":
          "${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}",
      "collab_type": _collab,
      "followup_date": _followupDate != null
          ? "${_followupDate!.year}-${_followupDate!.month.toString().padLeft(2, '0')}-${_followupDate!.day.toString().padLeft(2, '0')}"
          : null,
      "mode": _mode,
    };

    print("📤 Submitting SMU Form...");
    print("📦 API Body: $body");

    final repo = ReferralsRepositorysums();
    final response = await repo.recordSmus(body);

    print("✅ API Success Response: $response");

    _loadSmus(); // refresh list after adding

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response['message'] ?? 'SMU recorded successfully.'),
        backgroundColor: Colors.green,
      ),
    );

    if (resetAfter) _resetForm();
  } catch (e) {
    print("❌ API Error: $e");

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
    // Instead of disposing, just clear the controllers
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
    _formKey.currentState?.reset();
  });
}


Future<void> _loadSmus() async {
  print("🔄 Fetching SMU records...");
  try {
    final repo = ReferralsRepositorysums();
    final response = await repo.fetchSmusRecords();
    print("✅ SMU Records fetched successfully!");
    print("📊 Total Records: ${response.records.length}");
  } catch (e) {
    print("❌ Error fetching SMUs: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }
}


  // ---------------- Build ----------------
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
                icon: const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF014576),
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
                      DropdownButtonFormField<String>(
                        value: _selectedMyIglooMember,
                        items: _myIglooMembers.map((String member) {
                          return DropdownMenuItem<String>(
                            value: member,
                            child: Text(
                              member,
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedMyIglooMember = val;
                            if (val != null) {
                              _toController.text = val;
                              _selectedMemberName = null;
                            }
                          });
                        },
                        decoration: _inputDecoration("Select a member"),
                      ),
                      const SizedBox(height: 16),

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
