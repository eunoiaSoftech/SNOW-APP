import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/Data/Repositories/New%20Repositories/sgf/sgf_repo.dart';
import 'package:snow_app/Data/models/New%20Model/sgf_record_model.dart';
import 'package:snow_app/common%20api/all_business_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AbstractSFG extends StatefulWidget {
  const AbstractSFG({Key? key}) : super(key: key);

  @override
  _AbstractSFGState createState() => _AbstractSFGState();
}

class _AbstractSFGState extends State<AbstractSFG> {
  final SfgRepository _repo = SfgRepository();

  DateTime? startDate;
  DateTime? endDate;
  List<SfgItem> records = [];
  bool isLoading = true;
  Map<int, String> businessNameMap = {};
  int _viewMode = 0; // 0=All, 1=Created for me, 2=Created by me

  @override
  void initState() {
    super.initState();
    loadBusinessNames().then((_) => fetchData());
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();

      final response = await _repo.fetchSfgList(
        filterForMe: _viewMode == 1,
        showOnlyMy: _viewMode == 2,
      );

      setState(() {
        records = response.data; // NEW MODEL → response.data
      });

      print("🎯 Total records fetched: ${records.length}");
    } catch (e) {
      print("⚠️ Error fetching SFG list: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to load records")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> loadBusinessNames() async {
    try {
      final repo = DirectoryBusinessRepository();
      final response = await repo.fetchAllActiveBusinesses();

      businessNameMap = {
        for (var b in response.data) b.id!: b.data.businessName ?? "Unknown",
      };

      print("📌 Loaded ${businessNameMap.length} business names");
    } catch (e) {
      print("⚠️ Failed to load business names: $e");
    }
  }

  String _formatDate(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart)
          startDate = picked;
        else
          endDate = picked;
      });
    }
  }

  void _applyFilter() => fetchData();
  void _resetFilter() {
    setState(() {
      startDate = null;
      endDate = null;
    });
    fetchData();
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
              "Abstract SFGS",
              style: GoogleFonts.poppins(
                color: const Color(0xFF014576),
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
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
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ChoiceChip(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    labelPadding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    label: Text(
                      "All",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: _viewMode == 0,
                    onSelected: (_) {
                      setState(() => _viewMode = 0);
                      fetchData();
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 5,
                  child: ChoiceChip(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    labelPadding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    label: Text(
                      "Created for me",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: _viewMode == 1,
                    onSelected: (_) {
                      setState(() => _viewMode = 1);
                      fetchData();
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 5,
                  child: ChoiceChip(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    labelPadding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    label: Text(
                      "Created by me",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: _viewMode == 2,
                    onSelected: (_) {
                      setState(() => _viewMode = 2);
                      fetchData();
                    },
                  ),
                ),
              ],
            ),
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
        child: records.isEmpty
            ? const Center(child: Text("No records found"))
            : ListView.builder(
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final r = records[index];
                  return _buildRecordItem(
                    date: r.createdAt,
                    sogForm:
                    r.userName ??
                        "ID: ${r.opponentUserId}",
                    comment: r.comment,
                    amount: r.amount,
                  );
                },
              ),
      ),
    );
  }

  Widget _buildRecordItem({
    required String date,
    required String sogForm,
    required String comment,
    required String amount,
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
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Text(
            "Snowflakes Given To: $sogForm",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Comments: $comment",
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              amount,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
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
        Icon(icon, size: 20, color: Color(0xFF014576)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ],
    );
  }
}
