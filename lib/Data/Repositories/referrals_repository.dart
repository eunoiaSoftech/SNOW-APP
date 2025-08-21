import 'package:snow_app/Data/models/referral_model.dart';
import 'package:snow_app/Data/models/sfg_response.dart';
import 'package:snow_app/core/api_client.dart';
import '../models/sbog_response.dart';

class ReferralsRepository {
  final ApiClient apiClient;
  ReferralsRepository(this.apiClient);

  Future<CreateSbogResponse> createSbog({
    required int receiverId,
    required String leadName,
    required String leadEmail,
    required String leadPhone,
    required String message,
  }) async {
    final body = {
      "receiver_id": receiverId,
      "lead_name": leadName,
      "lead_email": leadEmail,
      "lead_phone": leadPhone,
      "message": message,
    };
    print(
      "POST URL: ${apiClient.dio.options.baseUrl}/api/v1/referrals/create-sbog",
    );
    print("Body: $body");

    final (response, statusCode) = await apiClient.post(
      "/referrals/create-sbog",
      body: body,
    );

    if (statusCode == 200 || statusCode == 201) {
      print("SBOG created successfully: ${response.data}");
      return CreateSbogResponse.fromJson(response.data);
    } else {
      print("Failed to create SBOG: ${response.data}");

      throw Exception("Failed to create SBOG: ${response.data}");
    }
  }

Future<MyReferralsResponse> getMyReferrals() async {
  print("🟢 [Repo] Starting getMyReferrals...");
  final (response, statusCode) = await apiClient.get(
    "/referrals/received-referrals",
  );
  print("🔵 [Repo] API responded with statusCode: $statusCode");

  if (statusCode == 200) {
    print("🟡 [Repo] Response Data: ${response.data}");
    try {
      final result = MyReferralsResponse.fromJson(response.data);
      print("🟠 [Repo] Parsed ${result.referrals?.length ?? 0} referrals");
      return result;
    } catch (e) {
      print("🔴 [Repo] Error parsing response: $e");
      throw Exception("Failed to parse referrals: $e");
    }
  } else {
    print("🔴 [Repo] Failed to fetch referrals: ${response.data}");
    throw Exception("Failed to fetch referrals: ${response.data}");
  }
}


  Future<RecordSfgResponse> createSSfg({
    required int leadId,
    required String status,
  }) async {
    final body = {"lead_id": leadId, "status": status};
    print(
      "POST URL: ${apiClient.dio.options.baseUrl}/api/v1/referrals/record-sfg",
    );
    print("Body: $body");

    final (response, statusCode) = await apiClient.post(
      "/referrals/record-sfg",
      body: body,
    );

    if (statusCode == 200 || statusCode == 201) {
      print("record-sfg created successfully: ${response.data}");
      return RecordSfgResponse.fromJson(response.data);
    } else {
      print("Failed to create record-sfg: ${response.data}");

      throw Exception("Failed to create record-sfg: ${response.data}");
    }
  }

  Future<List<Referral>> getReceivedReferrals() async {
  final (response, statusCode) = await apiClient.get(
    "/referrals/received-referrals",
  );

  if (statusCode == 200) {
    print("Fetched referrals successfully: ${response.data}");

    final data = response.data['received_referrals'] as List;
    return data.map((e) => Referral.fromJson(e)).toList();
  } else {
    print("Failed to fetch referrals: ${response.data}");
    throw Exception("Failed to fetch referrals: ${response.data}");
  }
}

}
