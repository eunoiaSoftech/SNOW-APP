import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/common api/admin_category_repository.dart';
import 'package:snow_app/Data/models/New Model/admin_business_category.dart';

class AdminCategoryListScreen extends StatefulWidget {
  const AdminCategoryListScreen({super.key});

  @override
  State<AdminCategoryListScreen> createState() =>
      _AdminCategoryListScreenState();
}

class _AdminCategoryListScreenState
    extends State<AdminCategoryListScreen> {
  final AdminCategoryRepository _repo = AdminCategoryRepository();

  List<AdminBusinessCategory> _categories = [];
  List<AdminBusinessCategory> _filtered = [];

  bool _loading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _searchController.addListener(_filter);
  }

  Future<void> _loadCategories() async {
    try {
      final list = await _repo.fetchBusinessCategories();

      setState(() {
        _categories = list;
        _filtered = list;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _filter() {
    final q = _searchController.text.toLowerCase();

    setState(() {
      _filtered = _categories.where((c) {
        return c.name.toLowerCase().contains(q);
      }).toList();
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
            iconTheme: const IconThemeData(color: Color(0xFF014576)),
            title: Text(
              "Business Categories",
              style: GoogleFonts.poppins(
                color: const Color(0xFF014576),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          body: Column(
            children: [
              // 🔍 SEARCH
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEAF5FC), Color(0xFFD8E7FA)],
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: "Search category...",
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(14),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _filtered.isEmpty
                        ? Center(
                            child: Text(
                              "No Categories Found",
                              style: GoogleFonts.poppins(),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filtered.length,
                            itemBuilder: (context, index) {
                              final c = _filtered[index];
                              return _buildCard(c);
                            },
                          ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(AdminBusinessCategory c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEAF5FC), Color(0xFFD8E7FA)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 NAME
          Text(
            c.name,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: const Color(0xFF014576),
            ),
          ),

          const SizedBox(height: 6),

          // 🔹 DESCRIPTION
          if ((c.description ?? "").isNotEmpty)
            Text(
              c.description!,
              style: GoogleFonts.poppins(fontSize: 13),
            ),

          const SizedBox(height: 8),

          // // 🔹 STATUS + DATE
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text(
          //       "Created: ${c.createdAt ?? ''}",
          //       style: GoogleFonts.poppins(
          //           fontSize: 11, color: Colors.grey[600]),
          //     ),

          //     Container(
          //       padding:
          //           const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          //       decoration: BoxDecoration(
          //         color: (c.isActive == "1"
          //                 ? Colors.green
          //                 : Colors.red)
          //             .withOpacity(0.2),
          //         borderRadius: BorderRadius.circular(20),
          //       ),
          //       child: Text(
          //         c.isActive == "1" ? "ACTIVE" : "INACTIVE",
          //         style: GoogleFonts.poppins(
          //           fontSize: 11,
          //           color: c.isActive == "1"
          //               ? Colors.green
          //               : Colors.red,
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}