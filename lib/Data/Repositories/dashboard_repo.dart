import 'package:snow_app/Data/models/dashboard_model.dart';
import 'package:snow_app/core/api_client.dart';


class HomeRepository {
  final ApiClient apiClient;

  HomeRepository(this.apiClient);

  Future<List<TopReceiver>> fetchTopReceivers() async {
    final (response, statusCode) = await apiClient.get('/states/top-receivers');

    if (statusCode == 200 && response.data['success'] == true) {
      List data = response.data['top_receivers'];
      return data.map((e) => TopReceiver.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load Top Receivers');
    }
  }

  Future<List<TopGiver>> fetchTopGivers() async {
    final (response, statusCode) = await apiClient.get('/states/top-givers');

    if (statusCode == 200 && response.data['success'] == true) {
      List data = response.data['top_givers'];
      return data.map((e) => TopGiver.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load Top Givers');
    }
  }
}
