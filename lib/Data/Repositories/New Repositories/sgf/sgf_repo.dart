import 'package:snow_app/Data/models/New%20Model/sgf_record_model.dart';
import 'package:snow_app/core/api_client.dart';

class SfgRepository {
  final ApiClient _api = ApiClient.create();


  Future<SfgListResponse> fetchSfgList({
    required int businessId,
    bool showOnlyMy = true,
  }) async {
    const endpoint = "router.php";

    final query = {
      "endpoint": "sfg/list",
      "show_only_my": showOnlyMy.toString(),
      "business_id": businessId.toString(),
    };

    final (res, code) = await _api.get(endpoint, query: query);

    if (code == 200) {
      return SfgListResponse.fromJson(res.data);
    } else {
      throw Exception("Error: ${res.data}");
    }
  }

  /// -----------------------
  /// CREATE SFG
  /// -----------------------
  Future<Map<String, dynamic>> createSfg({
    required int opponentUserId,
    required String amount,
    required String comment,
  }) async {
    const endpoint = "router.php";

    final query = {
      "endpoint": "sfg/create",
    };

    final body = {
      "opponent_user_id": opponentUserId,
      "amount": amount,
      "comment": comment,
    };

    final (res, code) = await _api.post(
      endpoint,
      query: query,
      body: body,
    );

    if (code == 200 || code == 201) {
      return res.data;
    } else {
      throw Exception("Failed: ${res.data}");
    }
  }
}
