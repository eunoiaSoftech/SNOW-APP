import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:snow_app/Data/Models/profile_overview.dart';

import '../../core/api_client.dart';
import '../../core/result.dart';

class ProfileRepository {
  ProfileRepository();

  final ApiClient _api = ApiClient.create();
  static Uri get _routerBase =>
      Uri.parse(dotenv.env['BASE_URL'] ?? '');

  Future<Result<ProfileOverview>> fetchProfile() async {
    final uri = _routerBase.replace(queryParameters: {'endpoint': 'user/profile'});
    final (res, code) = await _api.getUri(uri);
    if (code == 200 && res.data is Map<String, dynamic>) {
      return Ok(ProfileOverview.fromJson(res.data as Map<String, dynamic>));
    }
    return Err('Unable to fetch profile', code: code);
  }

  Future<Result<void>> switchUserType(int userTypeId) async {
    final uri = _routerBase.replace(queryParameters: {'endpoint': 'auth/switch-type'});
    final (res, code) = await _api.postUri(uri, body: {'user_type_id': userTypeId});
    if (code == 200) {
      return const Ok(null);
    }
    final msg = _extractError(res.data);
    return Err(msg, code: code);
  }

  String _extractError(dynamic data) {
    if (data is Map<String, dynamic>) {
      final msg = data['message'] ?? data['error'];
      if (msg is String && msg.isNotEmpty) {
        return msg;
      }
    }
    return 'Request failed';
  }
}