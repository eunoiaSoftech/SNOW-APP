class BusinessCategory {
  final int? id; // id can be null if it's a new category
  final String name;

  BusinessCategory({this.id, required this.name});

  factory BusinessCategory.fromJson(Map<String, dynamic> json) {
    return BusinessCategory(
      id: json['id'] as int?,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
    };
  }
}
