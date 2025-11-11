import 'package:flutter/material.dart';
import 'package:snow_app/Data/Repositories/auth_repository.dart';
import 'package:snow_app/core/app_toast.dart';
import 'package:snow_app/core/validators.dart';
import 'package:snow_app/logins/login.dart';

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

  @override
  void dispose() {
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
        context.showToast('OTP sent. Check your email.');
        setState(() => _stage = _ResetStage.verify);
      case Err(message: final msg, code: final code):
        final suffix = code > 0 ? ' ($code)' : '';
        context.showToast('Failed to send OTP$suffix: $msg', bg: Colors.red);
    }
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
        context.showToast('OTP verification failed$suffix: $msg', bg: Colors.red);
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      context.showToast('Enter a valid password');
      return;
    }
    if (_resetToken == null) {
      context.showToast('Missing reset token. Restart the process.', bg: Colors.red);
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
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      offset: Offset(0, 5),
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
                            ? 'Enter the email associated with your account.'
                            : _stage == _ResetStage.verify
                                ? 'Enter the OTP sent to your email. (Dev OTP: 1111)'
                                : 'Create a strong new password to secure your account.',
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
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                        ),
                      if (_stage == _ResetStage.verify) ...[
                        TextFormField(
                          controller: _otpController,
                          decoration: const InputDecoration(
                            labelText: 'OTP',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) => Validators.required(v, label: 'OTP'),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                      if (_stage == _ResetStage.reset) ...[
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'New Password',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => Validators.minLen(v, 6, label: 'Password'),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _onSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5E9BC8),
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
                      const SizedBox(height: 12),
                      if (_stage == _ResetStage.verify)
                        TextButton(
                          onPressed: _loading ? null : () => setState(() => _stage = _ResetStage.request),
                          child: const Text('Resend OTP'),
                        ),
                    ],
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

enum _ResetStage { request, verify, reset }
