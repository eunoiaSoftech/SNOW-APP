class DirectoryUservisitor {
  final int id;
  
  final String fullName;
  final String businessName;

  DirectoryUservisitor({
    required this.id,
    required this.fullName,
    required this.businessName,
  });

  factory DirectoryUservisitor.fromJson(Map<String, dynamic> json) {
    return DirectoryUservisitor(
      id: json['user_id'], // 🔥 IMPORTANT
      fullName: json['data']['full_name'] ?? '',
      businessName: json['data']['business_name'] ?? '',
    );
  }
}