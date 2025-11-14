import 'package:snow_app/common%20api/all_business_directory_model.dart';
import 'package:snow_app/core/api_client.dart';

class DirectoryBusinessRepository {
  final ApiClient _api = ApiClient.create();

  Future<BusinessDirectoryResponse> fetchAllActiveBusinesses() async {
    const endpoint = "/";  // <-- FIXED
    const query = {
      "endpoint": "user/directory",
      "status": "ACTIVE",
    };

    try {
      final (res, code) = await _api.get(endpoint, query: query);

      if (code == 200) {
        return BusinessDirectoryResponse.fromJson(res.data);
      } else {
        throw Exception("Error: ${res.data}");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }
}
