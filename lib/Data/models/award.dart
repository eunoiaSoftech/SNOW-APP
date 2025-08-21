class Award {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final String? imageUrl;
  final DateTime? createdAt;

  Award({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.imageUrl,
    this.createdAt,
  });

  factory Award.fromJson(Map<String, dynamic> json) {
    return Award(
      id: int.tryParse(json['id'].toString()) ?? 0,
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
      "image_url": imageUrl,
    };
  }
}
