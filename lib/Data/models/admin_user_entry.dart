class AdminUserEntry {
  final int userTypeId;
  final int userId;
  final String email;
  final String displayName;
  final String userType;
  final String status;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime registeredAt;
  final int? approvedBy;
  final DateTime? approvedAt;
  final String? aadharFile;


  const AdminUserEntry({
    required this.userTypeId,
    required this.userId,
    required this.email,
    required this.displayName,
    required this.userType,
    required this.status,
    required this.data,
    required this.createdAt,
    required this.registeredAt,
    this.approvedBy,
    this.approvedAt,
    this.aadharFile,
  });

  factory AdminUserEntry.fromJson(Map<String, dynamic> json) => AdminUserEntry(
        userTypeId: _parseInt(json['user_type_id']),
        userId: _parseInt(json['user_id']),
        email: json['email']?.toString() ?? '',
        displayName: json['display_name']?.toString() ?? '',
        userType: json['user_type']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        data: (json['data'] as Map?)?.map((key, value) => MapEntry(key.toString(), value)) ?? const {},
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
        registeredAt: DateTime.tryParse(json['user_registered']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
        approvedBy: _parseNullableInt(json['approved_by']),
        approvedAt: json['approved_at'] == null
            ? null
            : DateTime.tryParse(json['approved_at'].toString()),
        aadharFile: json['aadhar_file']?.toString(),
      );
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? 0;
}

int? _parseNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}
