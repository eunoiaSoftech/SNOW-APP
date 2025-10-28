class NewCategoryModel {
  final int? id;
  final String name;
  final String slug;

  NewCategoryModel({this.id, required this.name, required this.slug});

  Map<String, dynamic> toJson() => {'name': name, 'slug': slug};

  factory NewCategoryModel.fromJson(Map<String, dynamic> json) {
    return NewCategoryModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
    );
  }
}
