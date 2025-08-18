class Validators {
  static String? required(String? v, {String label = 'This field'}) {
    if (v == null || v.trim().isEmpty) return '$label is required';
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
    return ok ? null : 'Enter a valid email';
  }

  static String? minLen(String? v, int n, {String label = 'Value'}) {
    if (v == null || v.length < n) return '$label must be at least $n chars';
    return null;
  }
}