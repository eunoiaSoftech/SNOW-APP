import 'package:dio/dio.dart';
import 'package:snow_app/core/api_client.dart';
import '../models/award.dart';

class AwardRepository {
  final ApiClient apiClient;

  AwardRepository(this.apiClient);

  Future<List<Award>> getAwards() async {
    final (res, status) = await apiClient.get("/award/awards");

    if (status == 200 && res.data['success'] == true) {
      final List awards = res.data['awards'];
      return awards.map((a) => Award.fromJson(a)).toList();
    }
    return [];
  }

  Future<Award?> createAward(Award award) async {
    final (res, status) =
        await apiClient.post("/award/create-award", body: award.toJson());

    if (status == 200 && res.data['success'] == true) {
      return Award(
        id: res.data['award_id'],
        userId: 0, // backend not sending here, adjust if needed
        title: award.title,
        description: award.description,
        imageUrl: award.imageUrl,
      );
    }
    return null;
  }

  Future<bool> deleteAward(int awardId) async {
    final (res, status) =
        await apiClient.post("/award/delete-award", body: {"award_id": awardId});

    return status == 200 && res.data['success'] == true;
  }
}
