class User {
  final int id;
  final String email;
  final String fullName;
  final String businessName;
  final String businessCategory;
  final String contact;
  final String city;
  final String status;
  final bool isAdmin;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.businessName,
    required this.businessCategory,
    required this.contact,
    required this.city,
    required this.status,
    required this.isAdmin,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
    id: j['user_id'] ?? j['id'] ?? 0, // 🔥 FIXED
    email: j['email'] ?? '',
    fullName: j['display_name'] ?? j['data']?['full_name'] ?? '', // 🔥 FIXED
    businessName: j['data']?['business_name'] ?? '',
    businessCategory: j['data']?['business_category'] ?? '',
    contact: j['data']?['contact'] ?? '',
    city: j['data']?['city']?.toString() ?? '',
    status: j['status'] ?? 'PENDING',
    isAdmin: j['is_admin'] ?? false,
  );
}
