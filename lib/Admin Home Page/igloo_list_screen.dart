import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/Data/Models/admin_igloo.dart';

class IglooListScreen extends StatefulWidget {
  final List<Igloo> igloos;

  const IglooListScreen({super.key, required this.igloos});

  @override
  State<IglooListScreen> createState() => _IglooListScreenState();
}

class _IglooListScreenState extends State<IglooListScreen> {
  late List<Igloo> filteredIgloos;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredIgloos = widget.igloos;
    _searchController.addListener(_filterIgloos);
  }

  void _filterIgloos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredIgloos = widget.igloos.where((igloo) {
        return igloo.name.toLowerCase().contains(query) ||
            (igloo.cityName?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            iconTheme: const IconThemeData(color: Color(0xFF014576)),
            title: Text(
              'Existing Igloos',
              style: GoogleFonts.poppins(
                color: const Color(0xFF014576),
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ),
          body: Column(
            children: [
              // Search bar
             Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
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
          blurRadius: 8,
          offset: Offset(2, 4),
        ),
      ],
    ),
    child: TextField(
      controller: _searchController,
      style: GoogleFonts.poppins(
        color: const Color(0xFF014576),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Icon(
            Icons.search_rounded,
            color: const Color(0xFF014576).withOpacity(0.9),
            size: 22,
          ),
        ),
        hintText: 'Search by name or city...',
        hintStyle: GoogleFonts.poppins(
          color: Colors.grey[600],
          fontSize: 14,
        ),
        border: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFF014576), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide:
              BorderSide(color: Colors.blueGrey.withOpacity(0.1), width: 0.5),
        ),
      ),
    ),
  ),
),


              Expanded(
                child: filteredIgloos.isEmpty
                    ? Center(
                        child: Text(
                          'No Igloos found.',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[700],
                            fontSize: 15,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredIgloos.length,
                        itemBuilder: (context, index) {
                          final igloo = filteredIgloos[index];
                          return _buildIglooCard(igloo);
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIglooCard(Igloo igloo) {
    final subtitle = [
      if (igloo.countryName != null) igloo.countryName,
      if (igloo.zoneName != null) igloo.zoneName,
      if (igloo.stateName != null) igloo.stateName,
      if (igloo.cityName != null) igloo.cityName,
    ].whereType<String>().join(' • ');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEAF5FC), Color(0xFFD8E7FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Igloo name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                igloo.name,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: const Color(0xFF014576),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF5E9BC8).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  igloo.mode.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF014576),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Location
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),

          const SizedBox(height: 8),

          // Meeting + Duration
          Row(
            children: [
              const Icon(Icons.access_time,
                  size: 16, color: Color(0xFF014576)),
              const SizedBox(width: 6),
              Text(
                'Meeting: ${igloo.meetingTime}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                igloo.durationType.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF014576),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Assignments
          Text(
            'Assignments: ${igloo.assignments.length}',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
