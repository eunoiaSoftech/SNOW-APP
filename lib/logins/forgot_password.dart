import 'package:flutter/material.dart';
import 'package:snow_app/Data/Repositories/auth_repository.dart';
import 'package:snow_app/core/app_toast.dart';
import 'package:snow_app/core/validators.dart';
import 'package:snow_app/logins/login.dart';
import 'dart:async';
import '../core/result.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();

  final _auth = AuthRepository();

  bool _loading = false;
  _ResetStage _stage = _ResetStage.request;
  String? _resetToken;

  int _secondsRemaining = 0;
  Timer? _timer;

  // 🔥 OTP values (NEW)
  List<String> otpValues = ["", "", "", ""];

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    if (!_formKey.currentState!.validate()) {
      context.showToast('Enter a valid email address');
      return;
    }
    setState(() => _loading = true);

    final res = await _auth.requestPasswordOtp(_emailController.text.trim());

    if (!mounted) return;
    setState(() => _loading = false);

    switch (res) {
      case Ok():
        context.showToast(
          'OTP sent. Valid for 10 minutes. Check inbox or spam.',
        );
        _startTimer();
        setState(() => _stage = _ResetStage.verify);

      case Err(message: final msg, code: final code):
        final suffix = code > 0 ? ' ($code)' : '';
        context.showToast('Failed to send OTP$suffix: $msg', bg: Colors.red);
    }
  }

  void _startTimer() {
    _timer?.cancel();

    setState(() {
      _secondsRemaining = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().isEmpty) {
      context.showToast('Enter the OTP sent to your email');
      return;
    }

    setState(() => _loading = true);

    final res = await _auth.verifyResetOtp(
      email: _emailController.text.trim(),
      otp: _otpController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _loading = false);

    switch (res) {
      case Ok(value: final token):
        context.showToast('OTP verified. Set a new password.');
        setState(() {
          _resetToken = token;
          _stage = _ResetStage.reset;
        });

      case Err(message: final msg, code: final code):
        final suffix = code > 0 ? ' ($code)' : '';
        context.showToast(
          'OTP verification failed$suffix: $msg',
          bg: Colors.red,
        );
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      context.showToast('Enter a valid password');
      return;
    }

    if (_resetToken == null) {
      context.showToast(
        'Missing reset token. Restart the process.',
        bg: Colors.red,
      );
      return;
    }

    setState(() => _loading = true);

    final res = await _auth.resetPassword(
      email: _emailController.text.trim(),
      resetToken: _resetToken!,
      newPassword: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    switch (res) {
      case Ok():
        context.showToast('Password updated. Please sign in.');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );

      case Err(message: final msg, code: final code):
        final suffix = code > 0 ? ' ($code)' : '';
        context.showToast('Reset failed$suffix: $msg', bg: Colors.red);
    }
  }

  void _onSubmit() {
    switch (_stage) {
      case _ResetStage.request:
        _requestOtp();
        break;
      case _ResetStage.verify:
        _verifyOtp();
        break;
      case _ResetStage.reset:
        _resetPassword();
        break;
    }
  }

  String _buttonLabel() {
    switch (_stage) {
      case _ResetStage.request:
        return 'Send OTP';
      case _ResetStage.verify:
        return 'Verify OTP';
      case _ResetStage.reset:
        return 'Update Password';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset('assets/bglogin.jpg', fit: BoxFit.cover),
          ),
          Container(color: Colors.black.withOpacity(0.3)),

          // 🔥 FIXED OVERFLOW
          // 🔥 FIXED OVERFLOW + CENTERED + PREMIUM FEEL
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.90),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 25,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          width: 360,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _stage == _ResetStage.request
                                      ? 'Forgot Password'
                                      : _stage == _ResetStage.verify
                                      ? 'Verify OTP'
                                      : 'Set New Password',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5E9BC8),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                Text(
                                  _stage == _ResetStage.request
                                      ? 'Enter your email. OTP will be sent (check spam).'
                                      : _stage == _ResetStage.verify
                                      ? 'Enter 4-digit OTP (valid for 10 mins)'
                                      : 'Create a strong new password.',
                                  style: const TextStyle(color: Colors.black54),
                                ),

                                const SizedBox(height: 24),

                                if (_stage == _ResetStage.request)
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: Validators.email,
                                  ),

                                if (_stage == _ResetStage.verify) ...[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: List.generate(4, (index) {
                                      return SizedBox(
                                        width: 60,
                                        child: TextField(
                                          textAlign: TextAlign.center,
                                          keyboardType: TextInputType.number,
                                          maxLength: 1,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          decoration: InputDecoration(
                                            counterText: "",
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onChanged: (val) {
                                            otpValues[index] = val;

                                            if (val.isNotEmpty && index < 3) {
                                              FocusScope.of(
                                                context,
                                              ).nextFocus();
                                            }

                                            _otpController.text = otpValues
                                                .join();
                                          },
                                        ),
                                      );
                                    }),
                                  ),

                                  const SizedBox(height: 16),

                                  if (_secondsRemaining > 0)
                                    Text(
                                      "Resend in $_secondsRemaining sec",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                ],

                                if (_stage == _ResetStage.reset)
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      labelText: 'New Password',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (v) => Validators.minLen(
                                      v,
                                      6,
                                      label: 'Password',
                                    ),
                                  ),

                                const SizedBox(height: 24),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _loading ? null : _onSubmit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF5E9BC8),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _loading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            _buttonLabel(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),

                                if (_stage == _ResetStage.verify)
                                  TextButton(
                                    onPressed:
                                        (_secondsRemaining == 0 && !_loading)
                                        ? _requestOtp
                                        : null,
                                    child: Text(
                                      style: TextStyle(
                                        color: _secondsRemaining == 0
                                            ? const Color(0xFF5E9BC8)
                                            : Colors.grey,
                                      ),
                                      _secondsRemaining == 0
                                          ? 'Resend OTP'
                                          : 'Wait $_secondsRemaining sec',
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

enum _ResetStage { request, verify, reset }
