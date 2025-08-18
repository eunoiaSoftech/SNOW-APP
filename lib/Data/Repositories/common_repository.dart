import 'package:snow_app/Data/Models/business_category.dart';

import '../../core/api_client.dart';
import '../../core/result.dart';

class CommonRepository {
  final ApiClient _api = ApiClient.create();

  Future<Result<List<BusinessCategory>>> fetchBusinessCategories() async {
    final (res, code) = await _api.get('/business/category');
    if (code == 200) {
      final list = (res.data as List<dynamic>)
          .map((e) => BusinessCategory.fromJson(e as Map<String, dynamic>))
          .toList();
      return Ok(list);
    }
    return Err('Failed to load categories', code: code);
  }
}