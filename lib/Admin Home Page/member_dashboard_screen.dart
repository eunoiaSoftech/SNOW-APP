import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/common api/member_metrics_repository.dart';
import 'package:snow_app/Data/models/New Model/APP SETTING/member_metrics_model.dart';

class MemberDashboardScreen extends StatefulWidget {
  const MemberDashboardScreen({super.key});

  @override
  State<MemberDashboardScreen> createState() => _MemberDashboardScreenState();
}

class _MemberDashboardScreenState extends State<MemberDashboardScreen> {
  final repo = MemberMetricsRepository();
  String selectedFilter = "monthly";
  List<MemberMetrics> data = [];
  bool loading = true;
  int currentPage = 1;
  bool isLoadingMore = false;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        _load(isRefresh: false);
      }
    });

    _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load({bool isRefresh = true}) async {
    if (isRefresh) {
      currentPage = 1;
      hasMore = true;
    } else {
      currentPage++; 
    }

    if (!hasMore) return;

    setState(() {
      if (isRefresh) {
        loading = true;
      } else {
        isLoadingMore = true;
      }
    });

    try {
      final res = await repo.fetchMetrics(
        period: selectedFilter,
        page: currentPage,
        perPage: 20,
      );

      setState(() {
        if (isRefresh) {
          data = res;
        } else {
          data.addAll(res);
        }

        // ✅ stop if no more data
        if (res.isEmpty || res.length < 20) {
          hasMore = false;
        }

        loading = false;
        isLoadingMore = false;
      });
    } catch (e) {
      debugPrint("❌ ERROR: $e");

      setState(() {
        loading = false;
        isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Member Dashboard",
          style: GoogleFonts.poppins(
            color: const Color(0xFF014576),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF014576)),
      ),
      body: Stack(
        children: [
          // Background Image and Gradient Overlay
          Positioned.fill(
            child: Image.asset('assets/bghome.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xAA97DCEB),
                    Color(0xAA5E9BC8),
                    Color(0xAA97DCEB),
                    Color(0xAA70A9EE),
                    Color(0xAA97DCEB),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                // --- FILTER BAR ---
                _buildFilterBar(),
                const SizedBox(height: 15),
                // --- METRICS LIST ---
                Expanded(
                  child: loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF014576),
                          ),
                        )
                      : data.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: data.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            if (index < data.length) {
                              return _MetricCard(item: data[index]);
                            } else {
                              return const Padding(
                                padding: EdgeInsets.all(12),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF014576),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip("Weekly", "weekly"),
          _buildFilterChip("Monthly", "monthly"),
          _buildFilterChip("Yearly", "yearly"),
          _buildFilterChip("Lifetime", "lifetime"),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF014576),
        backgroundColor: Colors.white.withOpacity(0.5),
        labelStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? Colors.white : const Color(0xFF014576),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected
                ? Colors.transparent
                : const Color(0xFF014576).withOpacity(0.3),
          ),
        ),
        onSelected: (_) {
          if (!isSelected) {
            setState(() => selectedFilter = value);
            _load();
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: const Color(0xFF014576).withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            "No metrics found for this period",
            style: GoogleFonts.poppins(
              color: const Color(0xFF014576),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final MemberMetrics item;
  const _MetricCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: const Border(
          left: BorderSide(color: Color(0xFF014576), width: 6),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Name & Business
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF014576).withOpacity(0.1),
                  child: Text(
                    item.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF014576),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF014576),
                        ),
                      ),
                      Text(
                        "${item.businessName} • ${item.category}",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.blueGrey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            // Count Metrics Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatPod("Gives", item.giveCount.toString(), Colors.green),
                _buildStatPod(
                  "Receives",
                  item.receiveCount.toString(),
                  Colors.orange,
                ),
                _buildStatPod(
                  "Tests",
                  item.testimonialCount.toString(),
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Currency Metrics
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF014576).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildCurrencyLabel("Booked", item.businessBooked),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.blue.withOpacity(0.2),
                  ),
                  Expanded(
                    child: _buildCurrencyLabel("Given", item.businessGiven),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPod(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF014576),
          ),
        ),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: 10,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w600,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyLabel(String label, double amount) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
        ),
        Text(
          "₹${amount.toStringAsFixed(0)}", // Rounded for cleaner UI
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF014576),
          ),
        ),
      ],
    );
  }
}
