import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:snow_app/Data/Models/location_option.dart';
import 'package:snow_app/Data/Repositories/New%20Repositories/EXTRA%20FEATURE/traning_reg.dart';
import 'package:snow_app/Data/Repositories/common_repository.dart';
import 'package:snow_app/core/result.dart';

class AdminCreateTrainingScreen extends StatefulWidget {
  const AdminCreateTrainingScreen({super.key});

  @override
  State<AdminCreateTrainingScreen> createState() => _AdminCreateTrainingScreenState();
}

class _AdminCreateTrainingScreenState extends State<AdminCreateTrainingScreen> {
  final repo = TrainingRepositoryNew();
  final _common = CommonRepository();

  // Controllers
  final titleController = TextEditingController();
  final trainingOfController = TextEditingController();
  final trainingByController = TextEditingController();
  final trainerNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final feeController = TextEditingController();

  String mode = "offline";
  DateTime? selectedDate;
  bool isLoading = false;
  bool isLocationLoading = false;

  // Location Selections
  List<CountryOption> countries = [];
  CountryOption? selectedCountry;
  ZoneOption? selectedZone;
  StateOption? selectedState;
  CityOption? selectedCity;

  final Color primaryDark = const Color(0xFF014576);

  @override
  void initState() {
    super.initState();
    loadLocations();
  }

  Future<void> loadLocations() async {
    setState(() => isLocationLoading = true);
    final locationResult = await _common.fetchLocations();

    if (mounted) {
      setState(() {
        isLocationLoading = false;
        switch (locationResult) {
          case Ok(value: final value):
            countries = value;
            break;
          case Err(message: final msg, code: _):
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
            break;
        }
      });
    }
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: primaryDark),
        ),
        child: child!,
      ),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<void> submit() async {
    if (titleController.text.isEmpty || selectedCity == null || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields"), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final success = await repo.createTraining(
        title: titleController.text.trim(),
        trainingOf: trainingOfController.text.trim(),
        trainingBy: trainingByController.text.trim(),
        trainerName: trainerNameController.text.trim(),
        cityId: selectedCity!.id,
        mode: mode,
        locationDetail: locationController.text.trim(),
        trainingDate: selectedDate!,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Training Created Successfully ✅"), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
      );
    }
    if (mounted) setState(() => isLoading = false);
  }

  Widget _buildGlassField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryDark, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          labelStyle: GoogleFonts.poppins(color: primaryDark.withOpacity(0.7)),
        ),
      ),
    );
  }

  Widget _buildGlassDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          icon: Icon(Icons.arrow_drop_down, color: primaryDark),
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: primaryDark, size: 20),
            border: InputBorder.none,
            labelStyle: GoogleFonts.poppins(color: primaryDark.withOpacity(0.7)),
          ),
        ),
      ),
    );
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
          "NEW TRAINING",
          style: GoogleFonts.poppins(color: primaryDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        iconTheme: IconThemeData(color: primaryDark),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/bghome.jpg', fit: BoxFit.cover)),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white.withOpacity(0.4), const Color(0xFF97DCEB).withOpacity(0.7)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                    ),
                    child: Column(
                      children: [
                        _buildGlassField(label: "Title", controller: titleController, icon: Icons.title),
                        Row(
                          children: [
                            Expanded(child: _buildGlassField(label: "Training Of", controller: trainingOfController, icon: Icons.category)),
                            const SizedBox(width: 10),
                            Expanded(child: _buildGlassField(label: "Training By", controller: trainingByController, icon: Icons.business)),
                          ],
                        ),
                        _buildGlassField(label: "Trainer Name", controller: trainerNameController, icon: Icons.person),
                        
                        const Divider(height: 30, color: Colors.white),
                        
                        _buildGlassDropdown<CountryOption>(
                          label: "Country",
                          value: selectedCountry,
                          icon: Icons.public,
                          items: countries.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                          onChanged: (val) => setState(() {
                            selectedCountry = val;
                            selectedZone = selectedState = selectedCity = null;
                          }),
                        ),
                        if (selectedCountry != null)
                          _buildGlassDropdown<ZoneOption>(
                            label: "Zone",
                            value: selectedZone,
                            icon: Icons.map,
                            items: (selectedCountry?.zones ?? []).map((z) => DropdownMenuItem(value: z, child: Text(z.name))).toList(),
                            onChanged: (val) => setState(() {
                              selectedZone = val;
                              selectedState = selectedCity = null;
                            }),
                          ),
                        if (selectedZone != null)
                          _buildGlassDropdown<StateOption>(
                            label: "State",
                            value: selectedState,
                            icon: Icons.location_city,
                            items: (selectedZone?.states ?? []).map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                            onChanged: (val) => setState(() {
                              selectedState = val;
                              selectedCity = null;
                            }),
                          ),
                        if (selectedState != null)
                          _buildGlassDropdown<CityOption>(
                            label: "City",
                            value: selectedCity,
                            icon: Icons.pin_drop,
                            items: (selectedState?.cities ?? []).map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                            onChanged: (val) => setState(() => selectedCity = val),
                          ),

                        _buildGlassField(label: "Detailed Address", controller: locationController, icon: Icons.home_work),
                        _buildGlassField(label: "Fee (e.g. Free or 500)", controller: feeController, icon: Icons.payments, keyboardType: TextInputType.number),
                        _buildGlassDropdown<String>(
                          label: "Mode",
                          value: mode,
                          icon: Icons.on_device_training,
                          items: const [
                            DropdownMenuItem(value: "offline", child: Text("Offline")),
                            DropdownMenuItem(value: "online", child: Text("Online")),
                          ],
                          onChanged: (value) => setState(() => mode = value!),
                        ),

                        // Date & Time Picker
                        InkWell(
                          onTap: pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                            decoration: BoxDecoration(
                              color: primaryDark.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: primaryDark.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_month, color: primaryDark),
                                const SizedBox(width: 12),
                                Text(
                                  selectedDate == null ? "Schedule Date & Time" : DateFormat("MMM dd, yyyy - hh:mm a").format(selectedDate!),
                                  style: GoogleFonts.poppins(color: primaryDark, fontWeight: FontWeight.w600),
                                ),
                                const Spacer(),
                                Icon(Icons.edit, size: 18, color: primaryDark),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        isLoading
                            ? CircularProgressIndicator(color: primaryDark)
                            : SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryDark,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    elevation: 5,
                                  ),
                                  child: Text(
                                    "CREATE TRAINING",
                                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}