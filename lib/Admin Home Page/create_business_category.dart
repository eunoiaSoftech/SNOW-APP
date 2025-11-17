import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snow_app/common%20api/admin_category_repository.dart';
import 'package:snow_app/core/app_toast.dart';

class AdminCreateBusinessCategory extends StatefulWidget {
  const AdminCreateBusinessCategory({super.key});

  @override
  State<AdminCreateBusinessCategory> createState() =>
      _AdminCreateBusinessCategoryState();
}

class _AdminCreateBusinessCategoryState
    extends State<AdminCreateBusinessCategory> {
  final AdminCategoryRepository _repo = AdminCategoryRepository();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _description = TextEditingController();

  bool _saving = false;

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
              "Create Business Category",
              style: GoogleFonts.poppins(
                color: const Color(0xFF014576),
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            iconTheme: const IconThemeData(color: Color(0xFF014576)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add New Category',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: const Color(0xFF014576),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _inputField('Category Name', controller: _name),
                  const SizedBox(height: 18),

                  _inputField('Description',
                      controller: _description,
                      minLines: 2,
                      maxLines: 5),
                  const SizedBox(height: 28),

                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _submit,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.add_circle_outline_rounded),
                      label: const Text("Create Category"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF014576),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _inputField(String label,
      {required TextEditingController controller,
      int minLines = 1,
      int maxLines = 1}) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF014576)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.85),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5E9BC8), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF014576), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

Future<void> _submit() async {
  final name = _name.text.trim();
  final desc = _description.text.trim();

  if (name.isEmpty) {
    context.showToast("Please enter a category name");
    return;
  }

  setState(() => _saving = true);

  try {
    final result = await _repo.createBusinessCategory(name, desc);

    // SUCCESS UI
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Category “$name” created successfully",
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
      ),
    );

    _name.clear();
    _description.clear();
  } catch (e) {
    // CLEAN ERROR MESSAGE
    final cleanError = e.toString()
        .replaceAll("Exception:", "")
        .replaceAll("Error:", "")
        .replaceAll(RegExp(r"\b\d{3}\b"), "") // removes 401/500 codes
        .trim();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          cleanError.isEmpty
              ? "Something went wrong. Please try again."
              : cleanError,
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
      ),
    );
  } finally {
    if (mounted) setState(() => _saving = false);
  }
}

}
