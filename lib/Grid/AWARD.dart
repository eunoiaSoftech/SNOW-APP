import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snow_app/Data/Repositories/award_repository.dart';
import 'package:snow_app/Data/models/award.dart';
import 'package:snow_app/core/api_client.dart';

class AwardsScreen extends StatefulWidget {
  @override
  State<AwardsScreen> createState() => _AwardsScreenState();
}

class _AwardsScreenState extends State<AwardsScreen>
    with SingleTickerProviderStateMixin {
  final repo = AwardRepositoryNew();

  List<Award> awards = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAwards();
  }

Future<void> loadAwards() async {
  setState(() => isLoading = true);

  try {
    final response = await repo.fetchAwards();
    setState(() {
      awards = response.data;
      isLoading = false;
    });
  } catch (e) {
    setState(() => isLoading = false);
  }
}

  Future<void> _showCreateDialog() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    File? pickedImage;
    final picker = ImagePicker();
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            content: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 204, 234, 249),
                    Color(0xFF70a1ff),
                    Color.fromARGB(255, 82, 190, 237),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200.withOpacity(0.5),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Create Your Award 🎉",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 4,
                            offset: Offset(1, 2),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: titleController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Title 📌",
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white24,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white54,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Awarded by 🏅",
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white24,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white54,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    pickedImage != null
                        ? Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white70,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white24,
                                  blurRadius: 12,
                                ),
                              ],
                              image: DecorationImage(
                                image: FileImage(pickedImage!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Text(
                            "🌟 No image selected",
                            style: TextStyle(
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                    const SizedBox(height: 14),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.white24,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        elevation: 2,
                        shadowColor: Colors.black45,
                      ),
                      icon: Icon(Icons.image, color: Colors.white),
                      label: Text("Pick Image 🎨"),
                      onPressed: () async {
                        final XFile? img = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (img != null) {
                          // Save image to permanent storage
                          final directory =
                              await getApplicationDocumentsDirectory();
                          final newPath =
                              '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
                          final File newImage = await File(
                            img.path,
                          ).copy(newPath);

                          setStateDialog(() => pickedImage = newImage);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white24,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                        onPressed: () async {
  if (titleController.text.trim().isEmpty ||
      descController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please fill all required fields 🌟'),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  // We keep pickedImage for the future (when backend supports image)
  // final award = Award(
  //   id: 0,
  //   userId: 0,
  //   title: titleController.text.trim(),
  //   description: descController.text.trim(),
  //   imageUrl: pickedImage?.path, // local only for now
  // );

  // 🔥 API call (title + description only, image later)
  final res = await repo.createAward(
    titleController.text.trim(),
    descController.text.trim(),
  );

  if (res['success'] == true) {
    await loadAwards();    // refresh UI
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Award created successfully 🥳'),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to create award ⚠️'),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
},
   style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 8,
                              shadowColor: Colors.black45,
                            ),
                            child: Text(
                              "Create",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color.fromARGB(255, 82, 190, 237),
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
          ),
        ),
      ),
    );
  }

  Future<void> _deleteAward(int awardId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 204, 234, 249),
                  Color.fromARGB(255, 80, 175, 239),
                  Color.fromARGB(255, 87, 205, 248),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(
                    255,
                    80,
                    175,
                    239,
                  ).withOpacity(0.6),
                  blurRadius: 24,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Confirm Delete',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 22,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 6)],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Are you sure you want to delete this award? ❗',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white24,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(
                          Icons.delete_forever,
                          color: Color.fromARGB(255, 82, 190, 237),
                          size: 20,
                        ),
                        label: Text(
                          'Delete',
                          style: TextStyle(
                            color: Color.fromARGB(255, 82, 190, 237),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 10,
                          shadowColor: const Color.fromARGB(
                            255,
                            80,
                            175,
                            239,
                          ).withOpacity(0.3),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // if (confirm == true) {
    //   final success = await repo.deleteAward(awardId);
    //   if (success) {
    //     setState(() {
    //       awards.removeWhere((a) => a.id == awardId);
    //     });
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text('Award deleted successfully 🗑️'),
    //         backgroundColor: Colors.green.shade400,
    //         behavior: SnackBarBehavior.floating,
    //       ),
    //     );
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Keep your original BG image and gradient container as is
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
              'Snow Wall Of Rewards',
              style: GoogleFonts.poppins(
                color: Color(0xFF014576),
                fontWeight: FontWeight.w600,
                fontSize: 20,
                shadows: [
                  Shadow(
                    blurRadius: 4,
                    color: Color.fromARGB(150, 200, 240, 255),
                    offset: Offset(1, 2),
                  ),
                ],
              ),
            ),
            iconTheme: IconThemeData(color: Color(0xFF014576)),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: GestureDetector(
                  onTap: _showCreateDialog,
                  child: Icon(
                    Icons.image_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : awards.isEmpty
              ? const Center(
                  child: Text(
                    "No awards found",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  itemCount: awards.length,
                  itemBuilder: (context, index) {
                    final award = awards[index];
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 400 + (index * 100)),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.4),
                            Colors.blue.shade100.withOpacity(0.15),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),

                        border: Border.all(
                          color: Colors.blue.shade200.withOpacity(0.35),
                          width: 1.4,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          children: [
                       
                       
                            // Stack(
                            //   children: [
                            //     award.imageUrl != null &&
                            //             award.imageUrl!.isNotEmpty
                            //         ? Image.network(
                            //             award.imageUrl!,
                            //             width: double.infinity,
                            //             height: 220,
                            //             fit: BoxFit.cover,
                            //             errorBuilder: (_, __, ___) =>
                            //                 Image.asset(
                            //                   'assets/placeholder.jpg',
                            //                   width: double.infinity,
                            //                   height: 220,
                            //                   fit: BoxFit.cover,
                            //                 ),
                            //           )
                            //         : Image.asset(
                            //             'assets/placeholder.jpg',
                            //             width: double.infinity,
                            //             height: 220,
                            //             fit: BoxFit.cover,
                            //           ),
                            //     Container(
                            //       height: 220,
                            //       decoration: BoxDecoration(
                            //         gradient: LinearGradient(
                            //           colors: [
                            //             Colors.transparent,
                            //             Colors.blue.shade900.withOpacity(0.3),
                            //           ],
                            //           begin: Alignment.topCenter,
                            //           end: Alignment.bottomCenter,
                            //         ),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                           
                           
                           
                           
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.80),
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(20),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.shade100.withOpacity(
                                      0.25,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, -2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.emoji_events_rounded,
                                              color: Color(0xFF014576),
                                              size: 22,
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              // Prevent overflowing title text
                                              child: Text(
                                                award.title,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF014576),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // IconButton(
                                      //   icon: Icon(Icons.delete_forever),
                                      //   color: Colors.redAccent,
                                      //   tooltip: 'Delete award',
                                      //   splashRadius: 22,
                                      //   onPressed: () => _deleteAward(award.id),
                                      // ),
                                    ],
                                  ),

                                  const SizedBox(height: 6),
                                  Text(
                                    "Awarded by ${award.description ?? 'Unknown'}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.black54,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
