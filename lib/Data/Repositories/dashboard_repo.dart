import 'package:snow_app/Data/models/dashboard_model.dart';
import 'package:snow_app/core/api_client.dart';

class HomeRepository {
  final ApiClient apiClient;

  HomeRepository(this.apiClient);

  Future<List<TopReceiver>> fetchTopReceivers() async {
    print("🔄 [API CALL] -> /states/top-receivers"); // Debug log
    final (response, statusCode) = await apiClient.get('/states/top-receivers');

    print("📡 Status Code: $statusCode"); // Debug log
    print("📦 Raw Response: ${response.data}"); // Debug log

    if (statusCode == 200 && response.data['success'] == true) {
      List data = response.data['top_receivers'] ?? [];
      print("📊 Parsed Top Receivers Count: ${data.length}"); // Debug log
      return data.map((e) => TopReceiver.fromJson(e)).toList();
    } else {
      print("❌ API Failed: ${response.data}"); // Debug log
      throw Exception('Failed to load Top Receivers');
    }
  }

  Future<List<TopGiver>> fetchTopGivers() async {
    print("🔄 [API CALL] -> /states/top-givers"); // Debug log
    final (response, statusCode) = await apiClient.get('/states/top-givers');

    print("📡 Status Code: $statusCode"); // Debug log
    print("📦 Raw Response: ${response.data}"); // Debug log

    if (statusCode == 200 && response.data['success'] == true) {
      List data = response.data['top_givers'] ?? [];
      print("📊 Parsed Top Givers Count: ${data.length}"); // Debug log
      return data.map((e) => TopGiver.fromJson(e)).toList();
    } else {
      print("❌ API Failed: ${response.data}"); // Debug log
      throw Exception('Failed to load Top Givers');
    }
  }
}
