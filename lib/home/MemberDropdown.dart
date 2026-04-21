import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MemberDropdown extends StatefulWidget {
  final List<dynamic> items; // Replace with your BusinessItem model
  final int? selectedId;
  final Function(dynamic) onSelected;

  const MemberDropdown({
    Key? key,
    required this.items,
    required this.selectedId,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<MemberDropdown> createState() => _MemberDropdownState();
}

class _MemberDropdownState extends State<MemberDropdown> {
  bool _isExpanded = false;

  // Your custom blue palette
  final List<Color> _bgGradient = const [
    Color(0xAA97DCEB),
    Color(0xAA5E9BC8),
    Color(0xAA97DCEB),
    Color(0xAA70A9EE),
    Color(0xAA97DCEB),
  ];

  final Color _primaryDark = const Color(0xFF014576);

  @override
  Widget build(BuildContext context) {
    final selectedItem = widget.items
        .where((e) => e.id == widget.selectedId)
        .toList()
        .firstOrNull;

    return Column(
      children: [
        /// 🔹 TOP SELECTOR (The "Header")
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _isExpanded ? const Color(0xFFF4F9FD) : Colors.white,

              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: _isExpanded
                    ? _primaryDark.withOpacity(0.5)
                    : Colors.grey.shade300,
                width: 1.5,
              ),
              boxShadow: _isExpanded
                  ? [
                      BoxShadow(
                        color: _primaryDark.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_search_rounded,
                  color: _primaryDark,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedItem == null
                        ? "Select a member"
                        : selectedItem.displayName,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: selectedItem != null
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: _primaryDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(Icons.expand_more_rounded, color: _primaryDark),
                ),
              ],
            ),
          ),
        ),

        /// 🔹 DROPDOWN LIST (The "Body")
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.fastOutSlowIn,
          margin: const EdgeInsets.only(top: 10),
          height: _isExpanded ? 320 : 0, // Constrained height
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: _isExpanded
                ? ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: widget.items.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: Colors.grey.shade50,
                      indent: 70, // Aligns divider with text, not avatar
                    ),
                    itemBuilder: (context, index) {
                      final item = widget.items[index];
                      final bool isSelected = item.id == widget.selectedId;

                      return InkWell(
                        onTap: () {
                          widget.onSelected(item);
                          setState(() => _isExpanded = false);
                        },
                        child: Container(
                          color: isSelected
                              ? _bgGradient.first.withOpacity(0.2)
                              : Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              // Premium Avatar with Border
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _primaryDark.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 22,
                                  backgroundColor: _primaryDark,
                                  child: Text(
                                    item.displayName.isNotEmpty
                                        ? item.displayName[0].toUpperCase()
                                        : "?",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.displayName,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: _primaryDark,
                                      ),
                                    ),
                                    Text(
                                      item.business.category ?? "Professional",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: _primaryDark,
                                  size: 20,
                                )
                              else
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.grey.shade300,
                                  size: 14,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
