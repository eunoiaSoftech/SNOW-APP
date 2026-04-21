import 'package:snow_app/core/api_client.dart';

class DirectoryMemberRepository {
  final ApiClient _api = ApiClient.create();

  Future<List<Map<String, dynamic>>> fetchMembers({
    int? cityId,
    int? iglooId,
  }) async {
    const endpoint = "/";

    final query = {
      "endpoint": "user/directory",
      "status": "ACTIVE",
      if (cityId != null) "city_id": cityId.toString(),
      if (iglooId != null) "igloo_id": iglooId.toString(),
    };

    final (res, code) = await _api.get(endpoint, query: query);

    if (code == 200 && res.data["success"] == true) {
      return List<Map<String, dynamic>>.from(res.data["data"]);
    } else {
      throw Exception("Failed to load members");
    }
  }
}