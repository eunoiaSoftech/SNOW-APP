import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import Screens
import 'package:snow_app/Grid/AWARD.dart';
import 'package:snow_app/Grid/UpcomingTrainingsScreen.dart';
import 'package:snow_app/Grid/myreferral.dart';
import 'package:snow_app/Grid/recived_referrals.dart';
import 'package:snow_app/Grid/meetup_create.dart';
import 'package:snow_app/SnowBusinessOpporuntines/RecordSBOL.dart';

import 'package:snow_app/Snowflakes/Recordsfg.dart';
import 'package:snow_app/Snowflakes/abstractofsfg.dart';

import 'package:snow_app/SnowBusinessOpporuntines/RecordSBOG.dart';
import 'package:snow_app/SnowBusinessOpporuntines/AbstractSBOG.dart';
import 'package:snow_app/SnowBusinessOpporuntines/AbstractSBOR.dart';

import 'package:snow_app/SnowMEETups/RecordSMUS.dart';
import 'package:snow_app/SnowMEETups/AbstractSMUS.dart';
import 'package:snow_app/core/module_access_service.dart';

class GradientGridScreen extends StatefulWidget {
  const GradientGridScreen({super.key});

  @override
  State<GradientGridScreen> createState() => _GradientGridScreenState();
}

class _GradientGridScreenState extends State<GradientGridScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _expandedTile;

  final Map<String, GlobalKey> _expansionTileKeys = {
    'snowflakes': GlobalKey(),
    'snowBusiness': GlobalKey(),
    'snowMeetups': GlobalKey(),
    'extraFeatures': GlobalKey(),
  };

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToExpanded(String keyName) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _expansionTileKeys[keyName]?.currentContext;
      if (context != null) {
        final renderObject = context.findRenderObject() as RenderBox;
        final offset = renderObject.localToGlobal(Offset.zero);
        final widgetHeight = renderObject.size.height;
        final screenHeight = MediaQuery.of(context).size.height;

        final double targetOffset =
            _scrollController.offset +
            offset.dy +
            widgetHeight -
            screenHeight +
            20;

        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final moduleService = ModuleAccessService();
    final hasSfg = moduleService.hasAccess('sfg');
    final hasSbog = moduleService.hasAccess('sbog');

    // ---------------- SNOWFLAKES ----------------
    final List<Map<String, dynamic>> snowflakesItems = [
      {
        "title": "Record SFG",
        "icon": Icons.assignment_turned_in,
        "screen": SnowflakesRecordSFG(),
      },
      {
        "title": "Abstract of SFG",
        "icon": Icons.description_rounded,
        "screen": AbstractSFG(),
      },
    ];

    // ---------------- SNOW BUSINESS OPPORTUNITIES ----------------
    final List<Map<String, dynamic>> snowBusinessItems = [
      {
        "title": "Record SBOG",
        "icon": Icons.receipt_long_rounded,
        "screen": RecordSBOG(),
      },
       {
        "title": "Record SBOL",
        "icon": Icons.business_center_rounded,
        "screen": RecordSBOL(),
      },
      {
        "title": "Abstract of SBOG",
        "icon": Icons.analytics_rounded,
        "screen": AbstractSBOGScreen(),
      },
      {
        "title": "Abstract of SBOR",
        "icon": Icons.insert_chart_rounded,
        "screen": AbstractSBOR(),
      },
    ];

    // ---------------- SNOW MEET UPS ----------------
    final List<Map<String, dynamic>> snowMeetupItems = [
      {
        "title": "Record SMUS",
        "icon": Icons.group_add_rounded,
        "screen": RecordSMUS(),
      },
      {
        "title": "Abstract of SMUS",
        "icon": Icons.groups_rounded,
        "screen": AbstractSMUS(),
      },
    ];

    // ---------------- EXTRA FEATURES ----------------
    final List<Map<String, dynamic>> extraItems = [
      {
        "title": "Awards",
        "icon": Icons.emoji_events_rounded,
        "screen": AwardsScreen(),
      },
      {
        "title": "Training",
        "icon": Icons.school_rounded,
        "screen": UpcomingTrainingsScreen(),
      },
      // {
      //   "title": "Received Referrals",
      //   "icon": Icons.mark_email_read_rounded,
      //   "screen": ReceivedReferralsScreen(),
      // },
      {
        "title": "Meetup List",
        "icon": Icons.ac_unit_rounded,
        "screen": MeetupListScreen(),
      },
    ];

    // ---------- FUNCTION TO BUILD GRID ----------
    Widget buildGrid(List<Map<String, dynamic>> items) {
      return GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: List.generate(items.length, (index) {
          final item = items[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => item["screen"]),
              );
            },
            child: GridTile(item["title"], item["icon"]),
          );
        }),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Image & Gradient Overlay
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

          // Header + Scrollable Grid Sections
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 40.0,
            ),
            child: Column(
              children: [
                SizedBox(height: 40),
                Center(
                  child: Text(
                    'Grid Menu',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF014576),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      
                      children: [
                        _buildExpansionTile(
                          context,
                          "SNOW Meet Ups",
                          Icons.people_alt_rounded,
                          buildGrid(snowMeetupItems),
                          _expansionTileKeys['snowMeetups']!,
                          'snowMeetups',
                        ),
                        if (hasSfg)
                          _buildExpansionTile(
                            context,
                            "SNOWFLAKES",
                            Icons.ac_unit_rounded,
                            buildGrid(snowflakesItems),
                            _expansionTileKeys['snowflakes']!,
                            'snowflakes',
                          ),
                        if (hasSbog)
                          _buildExpansionTile(
                            context,
                            "SNOW Business Opportunities",
                            Icons.business_center_rounded,
                            buildGrid(snowBusinessItems),
                            _expansionTileKeys['snowBusiness']!,
                            'snowBusiness',
                          ),
                        _buildExpansionTile(
                          context,
                          "Extra Features",
                          Icons.star_rate_rounded,
                          buildGrid(extraItems),
                          _expansionTileKeys['extraFeatures']!,
                          'extraFeatures',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------- Reusable Tile UI (for Grid + Expansion headers) ----------
  Widget _tileBox(String title, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEAF5FC), Color.fromARGB(255, 193, 218, 250)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 28, color: const Color(0xAA5E9BC8)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF014576),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionTile(
    BuildContext context,
    String title,
    IconData icon,
    Widget childGrid,
    GlobalKey key,
    String keyName,
  ) {
    return ExpansionTile(
      key: key,
      tilePadding: EdgeInsets.zero,
      maintainState: true,
      // REMOVE default animation by forcing zero duration
      childrenPadding: EdgeInsets.zero,
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      initiallyExpanded: _expandedTile == keyName,
      trailing: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xFF014576),
      ),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      expandedAlignment: Alignment.centerLeft,
      onExpansionChanged: (isExpanded) {
        setState(() => _expandedTile = isExpanded ? keyName : null);
        if (isExpanded) _scrollToExpanded(keyName);
      },
      title: _tileBox(title, icon),
      children: [
        AnimatedSize(
          duration: Duration(milliseconds: 180), // Smooth, subtle effect
          curve: Curves.easeOut,
          child: Column(
            children: [
              const SizedBox(height: 8),
              childGrid,
              const SizedBox(height: 18),
            ],
          ),
        ),
      ],
    );
  }
}

class GridTile extends StatefulWidget {
  final String title;
  final IconData icon;

  const GridTile(this.title, this.icon, {super.key});

  @override
  _GridTileState createState() => _GridTileState();
}

class _GridTileState extends State<GridTile> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: _isHovering
                ? [const Color(0xFF97DCEB), const Color(0xFFEAF5FC)]
                : [
                    const Color(0xFFEAF5FC),
                    const Color.fromARGB(255, 193, 218, 250),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: _isHovering
              ? [
                  BoxShadow(
                    color: const Color(0xAA5E9BC8).withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(4, 4),
                  ),
                ]
              : [
                  const BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: _isHovering ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                widget.icon,
                size: 38,
                color: const Color(0xFF014576),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF014576),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
