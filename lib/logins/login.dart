import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snow_app/core/app_toast.dart';
import 'package:snow_app/core/validators.dart';
import 'package:snow_app/home/dashboard.dart';
import 'package:snow_app/logins/sign_up.dart';
import 'package:snow_app/data/repositories/auth_repository.dart';
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
                  // ✅ Use MediaQuery instead of fixed 350px
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
                        // TextFormField(
                        //   controller: _password,
                        //   obscureText: true,
                        //   validator: (v) =>
                        //       Validators.minLen(v, 6, label: 'Password'),
                        //   decoration: const InputDecoration(
                        //     hintText: 'Password',
                        //     border: OutlineInputBorder(
                        //       borderRadius: BorderRadius.all(
                        //         Radius.circular(12),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(height: 16),
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
                                  ),
                                ),
                        ),
                        // const SizedBox(height: 12),
                        // const Text(
                        //   'Forgot Password',
                        //   style: TextStyle(color: Colors.grey),
                        // ),
                        // const SizedBox(height: 20),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: const [
                        //     Icon(Icons.facebook, color: Colors.blue),
                        //     SizedBox(width: 16),
                        //     Icon(Icons.g_mobiledata, color: Colors.red),
                        //     SizedBox(width: 16),
                        //     Icon(Icons.mail_outline, color: Colors.lightBlue),
                        //   ],
                        // ),
                        const SizedBox(height: 20),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpPage(),
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

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userFullName', v.user.fullName); 

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SnowDashboard()),
          (Route<dynamic> route) => false,
        );
        break;

      case Err(message: final msg, code: final code):
        final errorMessage = (msg != null && msg.isNotEmpty)
            ? msg
            : "Something went wrong ($code)";
        context.showToast(errorMessage, bg: Colors.red);
    }
  }
}
