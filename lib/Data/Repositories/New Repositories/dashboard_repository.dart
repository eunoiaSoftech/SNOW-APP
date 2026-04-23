import 'package:snow_app/Data/models/New Model/dashboard_model.dart';
import 'package:snow_app/core/api_client.dart';
import 'package:snow_app/core/result.dart';

class DashboardRepository {
  final ApiClient _client = ApiClient.create();

  Future<Result<DashboardModel>> fetchDashboard(String period) async {
    try {
      print("📡 CALLING DASHBOARD API...");
      print("📊 PERIOD: $period");

      final (res, status) = await _client.get(
        '',
        query: {
          "endpoint": "user/dashboard",
          "period": period, // 🔥 dynamic now
        },
      );

      print("✅ STATUS: $status");
      print("📦 RESPONSE: ${res.data}");

      if (status == 200 && res.data['success'] == true) {
        final model = DashboardModel.fromJson(res.data);

        print("🎯 PARSED DATA:");
        print("SMU: ${model.smu}");
        print("Opportunities: ${model.opportunities}");
        print("Trainings: ${model.trainings}");
        print("SnowPoints: ${model.snowPoints}");

        return Ok(model);
      } else {
        print("❌ API FAILED");
        return Err("Failed to fetch dashboard");
      }
    } catch (e) {
      print("💥 ERROR: $e");
      return Err(e.toString());
    }
  }
}