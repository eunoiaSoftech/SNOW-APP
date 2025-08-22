import 'package:snow_app/Data/models/meetup_list.dart';
import 'package:snow_app/core/api_client.dart';

class MeetupListRepository {
  final ApiClient apiClient;

  MeetupListRepository(this.apiClient);

  Future<MeetupListResponse> fetchMeetups() async {
    try {
      final (res, status) = await apiClient.post("/meetups/list");

      if (status == 200) {
        return MeetupListResponse.fromJson(res.data);
      } else {
        throw Exception("Failed to load meetups: ${res.data}");
      }
    } catch (e) {
      rethrow;
    }
  }
}
