
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snow_app/Admin%20Home%20Page/homewapper.dart';
import 'package:snow_app/common%20api/all_business_api.dart';
import 'package:snow_app/core/app_toast.dart';
import 'package:snow_app/core/validators.dart';
import 'package:snow_app/logins/forgot_password.dart';
import 'package:snow_app/data/repositories/auth_repository.dart';
import 'package:snow_app/logins/signup_type_screen.dart';
import '../core/result.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _repo = AuthRepository();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/bglogin.jpg', fit: BoxFit.cover),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xAA97DCEB),
                        Color(0xAA70A9EE),
                        Color(0xAA5E9BC8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  width: screenWidth > 400 ? 350 : screenWidth * 0.9,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Welcome!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5E9BC8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sign in and get started',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),

                        // Email Field
                        TextFormField(
                          controller: _email,
                          validator: Validators.email,
                          decoration: const InputDecoration(
                            hintText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextFormField(
                          controller: _password,
                          obscureText: _obscurePassword,
                          validator: (v) =>
                              Validators.minLen(v, 6, label: 'Password'),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Sign In Button
                        ElevatedButton(
                          onPressed: _loading ? null : _onLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5E9BC8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),

                        // ✨ Improved Forgot Password Section
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 14.0),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              splashColor: const Color(
                                0x335E9BC8,
                              ), // soft ripple
                              onTap: _loading
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const ForgotPasswordPage(),
                                        ),
                                      );
                                    },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.lock_reset_rounded,
                                    color: const Color(
                                      0xFF5E9BC8,
                                    ).withOpacity(0.85),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  ShaderMask(
                                    shaderCallback: (Rect bounds) {
                                      return const LinearGradient(
                                        colors: [
                                          Color(0xFF5E9BC8),
                                          Color(0xFF8ABDF0),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ).createShader(bounds);
                                    },
                                    child: const Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            Colors.white, // masked by gradient
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Sign Up Button
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SelectTypePage(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(color: Color(0xFF5E9BC8)),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Color(0xFF5E9BC8),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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

  // Future<void> _onLogin() async {
  //   if (!_formKey.currentState!.validate()) {
  //     context.showToast('Fix validation errors');
  //     return;
  //   }

  //   setState(() => _loading = true);

  //   final res = await _repo.login(
  //     email: _email.text.trim(),
  //     password: _password.text,
  //   );

  //   setState(() => _loading = false);

  //   switch (res) {
  //     case Ok(value: final v):
  //       context.showToast('Welcome, ${v.user.fullName}');

  //       SharedPreferences prefs = await SharedPreferences.getInstance();

  //       // Save basic user info
  //       await prefs.setBool('isLoggedIn', true);
  //       await prefs.setBool('isAdmin', v.user.isAdmin);
  //       await prefs.setString('userRole', v.user.isAdmin ? 'admin' : 'user');
  //       await prefs.setString('userFullName', v.user.fullName);

  //       // 🔥 Save user_id for SBOR
  //       await prefs.setInt('user_id', v.user.id);

  //       // 🔥 FETCH BUSINESS DIRECTORY TO FIND THIS USER'S BUSINESS
  //       print("🔹 Login successful for user: ${v.user.fullName}");
  //       print("🔹 Logged-in User ID: ${v.user.id}");

  //       try {
  //         final repo = DirectoryBusinessRepository();
  //         final directoryResponse = await repo.fetchAllActiveBusinesses();
  //         final businesses = directoryResponse.data;

  //         print("📌 Total businesses fetched: ${businesses.length}");

  //         for (var b in businesses) {
  //           print("➡ Business ID: ${b.id}, belongs to userId: ${b.userId}");
  //         }

  //         final myBusiness = businesses.firstWhere(
  //           (b) => b.userId == v.user.id,
  //           orElse: () => throw Exception("No business entry found for user"),
  //         );

  //         print("🎉 Found matching business! BusinessID = ${myBusiness.id}");

  //         final prefs = await SharedPreferences.getInstance();
  //         await prefs.setInt('business_id', myBusiness.id);
  //         await prefs.setInt('user_id', v.user.id);

  //         print("💾 Saved user_id: ${prefs.getInt("user_id")}");
  //         print("💾 Saved business_id: ${prefs.getInt("business_id")}");
  //       } catch (e) {
  //         print("❌ BUSINESS FETCH ERROR: $e");
  //       }

  //       print("🔹 Login successful for user: ${v.user.fullName}");
  //       print("🔹 Saving user_id: ${v.user.id}");
  //       print("🔹 Looking for business entry for user_id: ${v.user.id}");

  //       // Navigate to home
  //       Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) =>
  //               MainHome(role: v.user.isAdmin ? 'admin' : 'user'),
  //         ),
  //         (Route<dynamic> route) => false,
  //       );

  //       break;

  //     case Err(message: final msg, code: final code):
  //       final errorMessage = (msg != null && msg.isNotEmpty)
  //           ? msg
  //           : "Something went wrong ($code)";
  //       context.showToast(errorMessage, bg: Colors.red);
  //   }
  // }

 Future<void> _onLogin() async {

  
  if (!_formKey.currentState!.validate()) {
    context.showToast('Fix validation errors');
    return;
  }

  setState(() => _loading = true);

  final res = await _repo.login(
    email: _email.text.trim(),
    password: _password.text,
  );

  setState(() => _loading = false);

  switch (res) {
    case Ok(value: final v):
      context.showToast('Welcome, ${v.user.fullName}');
      final prefs = await SharedPreferences.getInstance();

      // ------------------------------
      // SAVE BASIC USER INFO
      // ------------------------------
      await prefs.setBool('isLoggedIn', true);
      await prefs.setBool('isAdmin', v.user.isAdmin);
      await prefs.setString('userRole', v.user.isAdmin ? 'admin' : 'user');
      await prefs.setString('userFullName', v.user.fullName);

      // save user_id
      await prefs.setInt('user_id', v.user.id);

      print("🔹 Login successful for user: ${v.user.fullName}");
      print("🔹 Logged-in User ID: ${v.user.id}");

      // -------------------------------------------------------------
      // BUSINESS DIRECTORY LOOKUP (KEEPING YOUR ORIGINAL LOGIC)
      // -------------------------------------------------------------
      try {
        final repo = DirectoryBusinessRepository();
        final directoryResponse = await repo.fetchAllActiveBusinesses();
        final businesses = directoryResponse.data;

        print("📌 Total businesses fetched: ${businesses.length}");

        for (var b in businesses) {
          print("➡ Business ID: ${b.id}, belongs to userId: ${b.userId}");
        }

        final myBusiness = businesses.firstWhere(
          (b) => b.userId == v.user.id,
          orElse: () => throw Exception("No business entry found for user"),
        );

        print("🎉 Found matching business! BusinessID = ${myBusiness.id}");

        await prefs.setInt('business_id', myBusiness.id);

        print("💾 Saved business_id: ${prefs.getInt("business_id")}");
        print("💾 Saved user_id: ${prefs.getInt("user_id")}");

      } catch (e) {
        print("❌ BUSINESS FETCH ERROR: $e");
      }

      // ------------------------------
      // ⭐ READ FINAL ROLE AGAIN
      // ------------------------------
      final finalRole = prefs.getString('userRole') ?? 'user';
      print("🔹 FINAL ROLE USED FOR NAVIGATION = $finalRole");

      // ------------------------------
      // NAVIGATE BASED ON CLEAN ROLE
      // ------------------------------
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => MainHome(role: finalRole)),
        (route) => false,
      );

      break;

    case Err(message: final msg, code: final code):
      final errorMessage =
          (msg != null && msg.isNotEmpty) ? msg : "Something went wrong ($code)";
      context.showToast(errorMessage, bg: Colors.red);
  }
}


}
