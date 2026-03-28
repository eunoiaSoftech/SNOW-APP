class AdminBusinessCategory {
  final int id;
  final String name;
  final String? description;
  final String? createdAt;
  final bool isActive;

  AdminBusinessCategory({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
    required this.isActive,
  });

  factory AdminBusinessCategory.fromJson(Map<String, dynamic> json) {
    return AdminBusinessCategory(
      id: int.tryParse(json['id'].toString()) ?? 0, // 🔥 FIX
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      createdAt: json['created_at']?.toString(),

      // 🔥 FIX (handles "1", 1, true)
      isActive: json['is_active'].toString() == '1',
    );
  }
}