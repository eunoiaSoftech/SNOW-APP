import 'package:snow_app/Data/Models/business_category.dart';
import '../../core/api_client.dart';
import '../../core/result.dart';
import '../models/business_item.dart';

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
}