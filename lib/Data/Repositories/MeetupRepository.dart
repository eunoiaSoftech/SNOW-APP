import 'package:dio/dio.dart';
import 'package:snow_app/Data/models/meetup_response.dart';
import 'package:snow_app/core/api_client.dart';

class MeetupRepository {
  final ApiClient apiClient;

  MeetupRepository(this.apiClient);

  Future<MeetupResponse> createMeetup(Map<String, dynamic> body) async {
    try {
      print("📤 Sending POST request to /meetups/create");
      print("📦 Request Body: $body");

      final (res, status) = await apiClient.post("/meetups/create", body: body);

      print("✅ Response Status: $status");
      print("✅ Response Data: ${res.data}");

      if (status == 200 || status == 201) {
        print("🎯 Meetup created successfully!");
        return MeetupResponse.fromJson(res.data);
      } else {
        print("❌ Failed with status: $status");
        throw Exception("Failed: ${res.data}");
      }
    } catch (e) {
      print("🔥 Error in createMeetup: $e");
      rethrow;
    }
  }
}
