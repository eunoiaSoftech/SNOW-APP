import 'package:snow_app/Data/Models/profile.dart';

import '../../core/api_client.dart';
import '../../core/result.dart';

class ProfileRepository {
  final ApiClient _api = ApiClient.create();

  Future<Result<ProfileModel>> getProfile() async {
    final (res, code) = await _api.get('/business/profile');
    if (code == 200) {
      return Ok(ProfileModel.fromJson(res.data));
    }
    return Err('Unable to fetch profile', code: code);
  }

  Future<Result<String>> updateProfile(Map<String, dynamic> body) async {
    final (res, code) = await _api.post('/business/update-profile', body: body);
    if (code == 200) {
      final msg = (res.data is Map && res.data['message'] is String)
          ? res.data['message'] as String
          : 'Profile updated successfully';
      return Ok(msg);
    }
    return Err('Update failed', code: code);
  }
}