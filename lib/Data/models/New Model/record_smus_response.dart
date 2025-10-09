import 'smus_record.dart';

class SmusResponse {
  final bool success;
  final int loggedInUser;
  final bool showOnlyMy;
  final int count;
  final List<SMUSRecord> records;

  SmusResponse({
    required this.success,
    required this.loggedInUser,
    required this.showOnlyMy,
    required this.count,
    required this.records,
  });

  factory SmusResponse.fromJson(Map<String, dynamic> json) {
    final recordsData = json['records'];

    return SmusResponse(
      success: json['success'] ?? false,
      loggedInUser: json['logged_in_user'] ?? 0,
      showOnlyMy: json['show_only_my'] ?? false,
      count: json['count'] ?? 0,
      records: (recordsData != null && recordsData is List)
          ? recordsData.map((e) => SMUSRecord.fromJson(e)).toList()
          : [], // ✅ handles null safely
    );
  }
}
