import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/Data/Repositories/New%20Repositories/SMU/smu_repo.dart';

class AbstractSMUS extends StatefulWidget {
  const AbstractSMUS({Key? key}) : super(key: key);

  @override
  _AbstractSMUSState createState() => _AbstractSMUSState();
}

class _AbstractSMUSState extends State<AbstractSMUS> {
  DateTime? startDate;
  DateTime? endDate;

  final ReferralsRepositorySmu _repo = ReferralsRepositorySmu();
  List<Map<String, dynamic>> allRecords = [];
  List<Map<String, dynamic>> filteredRecords = [];
  bool isLoading = false;
  String? errorMessage;
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchSmusData();
  }

Future<void> _fetchSmusData() async {
  setState(() {
    isLoading = true;
    errorMessage = null;
  });

  try {
    final response = await _repo.fetchSmuRecords();

    if (response.success && response.data.isNotEmpty) {
      allRecords = response.data.map((r) {
        return {
          "date": DateTime.tryParse(r.date) ?? DateTime.now(),
          "metWith": r.toName,
          "abstract": r.abstractText,
          "collaboration": r.collaborationType,
          "mode": r.mode,
          "nextFollowUp": DateTime.tryParse(r.followupDate) ?? DateTime.now(),
        };
      }).toList();

      filteredRecords = List.from(allRecords);
    } else {
      errorMessage = "No data available in table.";
    }
  } catch (e) {
    errorMessage = "Failed to fetch data. Please try again later.";
    debugPrint("❌ SMUS Fetch Error: $e");
  }

  setState(() {
    isLoading = false;
  });
}

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF014576),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF014576),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  void _applyFilter() {
    setState(() {
      if (startDate == null && endDate == null) {
        filteredRecords = List.from(allRecords);
      } else {
        filteredRecords = allRecords.where((record) {
          DateTime d = record["date"];
          if (startDate != null && d.isBefore(startDate!)) return false;
          if (endDate != null && d.isAfter(endDate!)) return false;
          return true;
        }).toList();
      }
    });
  }

  void _resetFilter() {
    setState(() {
      startDate = null;
      endDate = null;
      filteredRecords = List.from(allRecords);
    });
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
            centerTitle: true,
            title: Text(
              "Abstract SMUS",
              style: GoogleFonts.poppins(
                color: const Color(0xFF014576),
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            iconTheme: const IconThemeData(color: Color(0xFF014576)),
          ),
          body: Column(
            children: [
              // Main content: Date Filter + Records
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      _buildDateFilterCard(context),
                      const SizedBox(height: 14),
                      Expanded(child: _buildRecordsCard()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateFilterCard(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardTitle("Date Filters", Icons.filter_alt),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker(
                    "Start Date",
                    startDate,
                    () => _pickDate(context, true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDatePicker(
                    "End Date",
                    endDate,
                    () => _pickDate(context, false),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _applyFilter,
                      icon: const Icon(Icons.search, size: 18),
                      label: const Text("Search"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF014576),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: GoogleFonts.poppins(fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      onPressed: _resetFilter,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text("Reset"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF014576),
                        side: const BorderSide(color: Color(0xFF014576)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: GoogleFonts.poppins(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? value, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade100,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Color(0xFF014576),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    value == null
                        ? "Select"
                        : "${value.day}-${value.month}-${value.year}",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordsCard() {
    return Container(
      decoration: _cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF014576)),
              )
            : errorMessage != null
            ? Center(
                child: Text(
                  errorMessage!,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              )
            : ListView(
                children: [
                  _cardTitle("SMU Records", Icons.receipt_long),
                  const SizedBox(height: 14),
                  if (filteredRecords.isEmpty)
                    Center(
                      child: Text(
                        "No data available in table",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  for (var record in filteredRecords)
                    _buildRecordItem(
                      date:
                          "${record['date'].day}-${record['date'].month}-${record['date'].year}",
                      metWith: record['metWith'] ?? '-',
                      abstractText: record['abstract'] ?? '-',
                      collaboration: record['collaboration'] ?? '-',
                      mode: record['mode'] ?? '-',
                      nextFollowUp:
                          "${record['nextFollowUp'].day}-${record['nextFollowUp'].month}-${record['nextFollowUp'].year}",
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildRecordItem({
    required String date,
    required String metWith,
    required String abstractText,
    required String collaboration,
    required String mode,
    required String nextFollowUp,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Met With: $metWith",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Abstract: $abstractText",
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
          ),
          const SizedBox(height: 6),
          Text(
            "Collaboration: $collaboration",
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey[700],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Mode of Meeting: $mode",
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey[700],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Next Followup Date: $nextFollowUp",
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
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
    );
  }

  Widget _cardTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF014576)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ],
    );
  }
}
