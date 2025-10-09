import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/Data/Repositories/New%20Repositories/SBOG%20REPO/recordSbog.dart';
import 'package:snow_app/Data/models/New%20Model/abs_sbog.dart';

class AbstractSBOGScreen extends StatefulWidget {
  const AbstractSBOGScreen({Key? key}) : super(key: key);

  @override
  _AbstractSBOGScreenState createState() => _AbstractSBOGScreenState();
}

class _AbstractSBOGScreenState extends State<AbstractSBOGScreen> {
  final ReferralsRepositorySbog _repo = ReferralsRepositorySbog();

  DateTime? startDate;
  DateTime? endDate;
  bool isLoading = false;
  String? error;
  List<SbogAbsRecord> records = [];

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await _repo.fetchSbogRecords(
        startDate: startDate,
        endDate: endDate,
      );
      setState(() {
        records = response.records ?? [];
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() => isLoading = false);
    }
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
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF014576),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Color(0xFF014576)),
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

  void _applyFilter() => _fetchRecords();

  void _resetFilter() {
    setState(() {
      startDate = null;
      endDate = null;
    });
    _fetchRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background
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
              "Abstract SBOG",
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
              // Running Users Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: _cardDecoration(),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      childrenPadding: const EdgeInsets.only(bottom: 12),
                      title: Text(
                        "Running Users",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF014576),
                        ),
                      ),
                      children: [
                        _buildRunningUser(
                          name: "Praveen Pawar",
                          time: "22-Sep-25 02:38 PM",
                          company: "SNOW PANTHERS",
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Filters + Records
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    children: [
                      _buildDateFilterCard(context),
                      const SizedBox(height: 14),
                      Expanded(child: _buildRecordsSection()),
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

  Widget _buildRunningUser({
    required String name,
    required String time,
    required String company,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: const Icon(Icons.person, color: Colors.blue),
      ),
      title: Text(
        name,
        style: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Active at: $time",
              style:
                  GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
          Text("IGLOO: $company",
              style:
                  GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
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
            _cardTitle("Select date range to view slips", Icons.filter_alt),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker(
                      "Start Date", startDate, () => _pickDate(context, true)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDatePicker(
                      "End Date", endDate, () => _pickDate(context, false)),
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
                            horizontal: 14, vertical: 10),
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
                            horizontal: 14, vertical: 10),
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
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87)),
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
                const Icon(Icons.calendar_today,
                    size: 16, color: Color(0xFF014576)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    value == null
                        ? "dd-mm-yyyy"
                        : "${value.day}-${value.month}-${value.year}",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordsSection() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(
        child: Text("Error: $error",
            style:
                GoogleFonts.poppins(color: Colors.redAccent, fontSize: 14)),
      );
    }
    if (records.isEmpty) {
      return Center(
        child: Text("No data available in table",
            style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600])),
      );
    }

    return Container(
      decoration: _cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _cardTitle("Snowflakes Records", Icons.receipt_long),
            const SizedBox(height: 14),
            for (var record in records)
              _buildRecordItem(
                date: record.date ?? '',
                sbogTo: record.sbogTo ?? '',
                referral: record.referral ?? '',
                phone: record.phone ?? '',
                email: record.email ?? '',
                comment: record.comment ?? '',
                level: record.level ?? '',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordItem({
    required String date,
    required String sbogTo,
    required String referral,
    required String phone,
    required String email,
    required String comment,
    required String level,
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
          Text("Date: $date",
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700])),
          const SizedBox(height: 6),
          Text("SBOG TO: $sbogTo",
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
          const SizedBox(height: 6),
          Text("Referral: $referral",
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700])),
          Text("Phone: $phone",
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700])),
          Text("Email: $email",
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700])),
          Text("Comments: $comment",
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700])),
          const SizedBox(height: 10),
          Text("Level of Connect: $level",
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueGrey[700])),
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
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 10,
          offset: Offset(2, 4),
        ),
      ],
    );
  }

  Widget _cardTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF014576)),
        const SizedBox(width: 8),
        Text(title,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, fontSize: 16)),
      ],
    );
  }
}
