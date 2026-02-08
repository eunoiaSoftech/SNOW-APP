import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:snow_app/Data/Models/business_category.dart';

import '../../core/api_client.dart';
import '../../core/result.dart';
import '../models/business_item.dart';
import '../Models/location_option.dart';

class CommonRepository {
  CommonRepository();

  final ApiClient _api = ApiClient.create();
  static Uri get _routerBase =>
      Uri.parse(dotenv.env['BASE_URL'] ?? '');

  Future<Result<List<BusinessCategory>>> fetchBusinessCategories() async {
    final uri = _routerBase.replace(queryParameters: {'endpoint': 'business-category/list'});
    final (res, code) = await _api.getUri(uri);
    if (code == 200) {
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final list = (data['data'] as List<dynamic>? ?? [])
            .map((e) => BusinessCategory.fromJson(e as Map<String, dynamic>))
            .toList();
        return Ok(list);
      }
    }
    return Err(_extractMessage(res.data, 'Failed to load categories'), code: code);
  }

  Future<Result<List<CountryOption>>> fetchLocations() async {
    final uri = _routerBase.replace(queryParameters: {'endpoint': 'location/list'});
    final (res, code) = await _api.getUri(uri);
    if (code == 200) {
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final list = (data['data'] as List<dynamic>? ?? [])
            .map((e) => CountryOption.fromJson(e as Map<String, dynamic>))
            .toList();
        return Ok(list);
      }
    }
    return Err(_extractMessage(res.data, 'Failed to load locations'), code: code);
  }

  Future<Result<List<CustomBusinessItem>>> fetchBusiness() async {
    final (res, code) = await _api.get('/business?page=1');
    if (code == 200) {
      final list = (res.data['data'] as List<dynamic>)
          .map((e) => CustomBusinessItem.fromJson(e as Map<String, dynamic>))
          .toList();
      return Ok(list);
    }
    return Err('Failed to load categories', code: code);
  }

  String _extractMessage(dynamic data, String fallback) {
    if (data is Map<String, dynamic>) {
      final msg = data['message'] ?? data['error'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    return fallback;
  }
}