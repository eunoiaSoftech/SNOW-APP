class DirectoryUserPublic {
  final int id;
  final String fullName;
  final String businessName;

  DirectoryUserPublic({
    required this.id,
    required this.fullName,
    required this.businessName,
  });

  factory DirectoryUserPublic.fromJson(Map<String, dynamic> json) {
    return DirectoryUserPublic(
      id: json['id'] ?? 0,
      fullName: json['username'] ?? '',
      businessName: json['business_name'] ?? '',
    );
  }
}

class DirectoryUserPrivate {
  final int id;
  final String fullName;
  final String businessName;

  DirectoryUserPrivate({
    required this.id,
    required this.fullName,
    required this.businessName,
  });

  factory DirectoryUserPrivate.fromJson(Map<String, dynamic> json) {
    return DirectoryUserPrivate(
      id: json['id'] ?? 0,
      fullName: json['user']?['full_name'] ?? '',
      businessName: json['business']?['name'] ?? '',
    );
  }
}