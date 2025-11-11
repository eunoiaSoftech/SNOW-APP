class AdminModule {
  final int id;
  final String slug;
  final String name;
  final String description;
  final bool isActive;
  final int createdBy;
  final DateTime createdAt;
  final bool isEnabled;

  const AdminModule({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.isEnabled,
  });

  factory AdminModule.fromJson(Map<String, dynamic> json) => AdminModule(
        id: _parseInt(json['id']),
        slug: json['slug']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        isActive: json['is_active'].toString() == '1' || json['is_active'] == true,
        createdBy: _parseInt(json['created_by']),
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
        isEnabled: json['is_enabled'].toString() == '1' || json['is_enabled'] == true,
      );
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? 0;
}
