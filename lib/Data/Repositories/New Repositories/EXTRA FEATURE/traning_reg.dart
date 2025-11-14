import 'package:snow_app/Data/models/New%20Model/extra%20feature/traning_reg.dart';
import 'package:snow_app/core/api_client.dart';

class TrainingRepositoryNew {
  final ApiClient _api = ApiClient.create();

  /// 🔹 LIST TRAININGS
  Future<TrainingListResponse> fetchTrainings() async {
    const endpoint = "router.php";

    final query = {
      "endpoint": "training/list",
    };

    final (res, code) = await _api.get(endpoint, query: query);

    if (code == 200) {
      return TrainingListResponse.fromJson(res.data);
    } else {
      throw Exception("Error loading trainings: ${res.data}");
    }
  }

  /// 🔹 CREATE TRAINING
  Future<Map<String, dynamic>> createTraining(Map<String, dynamic> body) async {
    const endpoint = "router.php";

    final query = {
      "endpoint": "training/create",
    };

    final (res, code) =
        await _api.post(endpoint, query: query, body: body);

    if (code == 200 || code == 201) {
      return res.data;
    } else {
      throw Exception("Failed: ${res.data}");
    }
  }

  /// 🔹 REGISTER FOR TRAINING
  Future<Map<String, dynamic>> registerForTraining(int trainingId) async {
    const endpoint = "router.php";

    final query = {
      "endpoint": "training/register",
    };

    final body = {"training_id": trainingId};

    final (res, code) =
        await _api.post(endpoint, query: query, body: body);

    if (code == 200 || code == 201) {
      return res.data;
    } else {
      throw Exception("Failed: ${res.data}");
    }
  }
}
