import 'package:snow_app/Data/models/New%20Model/APP%20SETTING/app_settings_model.dart';
import 'package:snow_app/core/api_client.dart';

class AppSettingsRepository {
  final ApiClient _api = ApiClient.create();

  /// ✅ GET APP SETTINGS (Android / iOS)
  Future<AppSettingsModel?> fetchAppSettings(String platform) async {
    const endpoint = "router.php";

    final query = {
      "endpoint": "app/check-settings",
      "platform": platform, // android / ios
    };

    try {
      final (res, code) = await _api.get(endpoint, query: query);

      if (code == 200 && res.data['success'] == true) {
        return AppSettingsModel.fromJson(res.data);
      } else {
        throw Exception("App settings fetch failed");
      }
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }
}
