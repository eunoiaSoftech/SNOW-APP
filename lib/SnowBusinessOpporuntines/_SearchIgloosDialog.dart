import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchIgloosDialog extends StatefulWidget {
  final ValueChanged<String> onMemberSelected;
  const SearchIgloosDialog({Key? key, required this.onMemberSelected})
    : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SearchIgloosDialogState createState() => _SearchIgloosDialogState();
}

class _SearchIgloosDialogState extends State<SearchIgloosDialog> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _resetSearch() {
    setState(() {
      _firstNameController.clear();
      _lastNameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFFEAF5FC), Color(0xFFD8E7FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(28, 22, 28, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
            Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        "Search Cross IGLOO Members",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF014576),
                        ),
                      ),
                    ),
                    // Updated cross button: cleaner circular background
                    Material(
                      color: const Color.fromARGB(255, 154, 192, 240).withOpacity(0.1),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.pop(context),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.indigo,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              // Description
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "To search, input at least two characters in any of the fields below.",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.blueGrey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Name Fields
              Row(
                children: [
                  Expanded(
                    child: _buildDialogTextField(
                      'First Name',
                      _firstNameController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDialogTextField(
                      'Last Name',
                      _lastNameController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Dropdowns 1
              Row(
                children: [
                  Expanded(child: _buildDialogDropdown('Country')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDialogDropdown('Zone')),
                ],
              ),
              const SizedBox(height: 12),
              // Dropdowns 2
              Row(
                children: [
                  Expanded(child: _buildDialogDropdown('City')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDialogDropdown('IGLOO')),
                ],
              ),
              const SizedBox(height: 24),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF014576),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'SEARCH',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _resetSearch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'RESET',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.black87,
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
    );
  }

  Widget _buildDialogTextField(String hint, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.blueGrey[400],
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF014576), width: 1.5),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      style: GoogleFonts.poppins(fontSize: 15),
    );
  }

  Widget _buildDialogDropdown(String hint) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.blueGrey[400],
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF014576), width: 1.5),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      items: const [DropdownMenuItem(value: 'All', child: Text('All'))],
      onChanged: (value) {},
    );
  }
}
