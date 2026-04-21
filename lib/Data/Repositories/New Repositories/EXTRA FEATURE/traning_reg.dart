import 'package:snow_app/Data/models/New%20Model/extra%20feature/traning_reg.dart';
import 'package:snow_app/Data/models/admin_training_registration_model.dart';
import 'package:snow_app/core/api_client.dart';

class TrainingRepositoryNew {
  final ApiClient _api = ApiClient.create();

  /// 🔹 CREATE TRAINING
  Future<bool> createTraining({
    required String title,
    required String trainingOf,
    required String trainingBy,
    required String trainerName,
    required int cityId,
    required String mode,
    required String locationDetail,
    required DateTime trainingDate,
  }) async {
    const endpoint = "router.php";

    final query = {"endpoint": "training/create"};

    final body = {
      "title": title,
      "training_of": trainingOf,
      "training_by": trainingBy,
      "trainer_name": trainerName,
      "city_id": cityId,
      "mode": mode,
      "location_detail": locationDetail,
      "training_date": trainingDate.toIso8601String(),
    };

    try {
      final (res, code) = await _api.post(endpoint, query: query, body: body);

      if (code == 200 || code == 201) {
        return true;
      } else {
        throw Exception("Create failed: ${res.data}");
      }
    } catch (e) {
      throw Exception("Exception in createTraining: $e");
    }
  }

  Future<bool> registerForTraining({
    required int trainingId,
    required String fullName,
    required String email,
    required String phone,
  }) async {
    const endpoint = "router.php";

    final query = {"endpoint": "training/register"};

    final body = {
      "training_id": trainingId,
      "full_name": fullName,
      "email": email,
      "phone": phone,
    };

    try {
      final (res, code) = await _api.post(endpoint, query: query, body: body);

      if (code == 200 || code == 201) {
        return res.data["success"] == true;
      } else {
        if (code == 200 || code == 201) {
          return res.data["success"] == true;
        } else {
          throw Exception(res.data["message"] ?? "Something went wrong");
        }
      }
    } catch (e) {
      throw Exception("Exception in registerForTraining: $e");
    }
  }

  Future<TrainingListResponse> fetchTrainings({
    String? countryId,
    String? stateId,
    String? cityId,
  }) async {
    const endpoint = "router.php";

    final query = {
      "endpoint": "training/list",
      "country_id": countryId ?? "",
      "state_id": stateId ?? "",
      "city_id": cityId ?? "",
    };

    try {
      final (res, code) = await _api.get(endpoint, query: query);

      if (code == 200 && res.data != null) {
        return TrainingListResponse.fromJson(res.data);
      } else {
        throw Exception("Error loading trainings: ${res.data}");
      }
    } catch (e) {
      throw Exception("Exception in fetchTrainings: $e");
    }
  }

  /// 🔹 GET REGISTERED USERS
  Future<TrainingRegistrationResponse> getRegisteredUsers(
    int trainingId,
  ) async {
    const endpoint = "router.php";

    final query = {
      "endpoint": "admin/training-registrations",
      "training_id": trainingId,
    };

    final (res, code) = await _api.get(endpoint, query: query);

    if (code == 200) {
      return TrainingRegistrationResponse.fromJson(res.data);
    } else {
      throw Exception(res.data["message"] ?? "Failed to load users");
    }
  }

  /// 🔹 MARK ATTENDANCE
  Future<String> markAttendance(int registrationId) async {
    const endpoint = "router.php";

    final query = {"endpoint": "admin/training-attendance"};

    final body = {
      "registration_id": registrationId,
      "attendance_status": "ATTENDED",
    };

    final (res, code) = await _api.post(endpoint, query: query, body: body);

    if (code == 200) {
      return res.data["message"];
    } else {
      throw Exception(res.data["message"]);
    }
  }
}
