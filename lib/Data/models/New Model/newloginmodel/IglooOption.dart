class IglooOption {
  final int id;
  final String name;

  IglooOption({
    required this.id,
    required this.name,
  });

  factory IglooOption.fromJson(Map<String, dynamic> json) {
    return IglooOption(
      id: _parseId(json['id']), // 🔥 FIXED
      name: json['name'] ?? '',
    );
  }

  @override
  String toString() => name;
}

// 🔥 ADD THIS FUNCTION
int _parseId(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
  
}
