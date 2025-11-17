class AdminBusinessCategory {
  final int id;
  final String name;
  final String? description;

  AdminBusinessCategory({
    required this.id,
    required this.name,
    this.description,
  });

  factory AdminBusinessCategory.fromJson(Map<String, dynamic> json) {
    return AdminBusinessCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}
