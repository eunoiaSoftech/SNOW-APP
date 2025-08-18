class BusinessCategory {
  final int id;
  final String name;
  final String slug;

  const BusinessCategory({required this.id, required this.name, required this.slug});

  factory BusinessCategory.fromJson(Map<String, dynamic> j) => BusinessCategory(
        id: (j['id'] ?? 0) is String ? int.tryParse(j['id']) ?? 0 : j['id'] ?? 0,
        name: j['name'] ?? '',
        slug: j['slug'] ?? '',
      );
}