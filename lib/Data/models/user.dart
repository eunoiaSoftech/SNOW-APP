class User {
  final int id;
  final String email;
  final String fullName;
  final String? businessName;
  final String? businessCategory; // id or name depending on API
  final String? contact;
  final String? city;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.businessName,
    this.businessCategory,
    this.contact,
    this.city,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: (j['id'] ?? 0) is String ? int.tryParse(j['id']) ?? 0 : j['id'] ?? 0,
        email: j['email'] ?? '',
        fullName: j['full_name'] ?? j['fullName'] ?? '',
        businessName: j['business_name'] ?? j['businessName'],
        businessCategory: j['business_category']?.toString(),
        contact: j['contact']?.toString(),
        city: j['city'],
      );
}