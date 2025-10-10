import 'package:snow_app/Data/models/New%20Model/allfetchbusiness.dart';
import 'package:snow_app/core/api_client.dart';
import 'package:snow_app/core/result.dart';

class BusinessRepository {
  final ApiClient _api = ApiClient.create();

  /// Fetch business with filters
  Future<Result<List<BusinessItem>>> fetchBusiness({
    String industry = '',
    int page = 1,
    String country = '',
    bool showAll = true,
  }) async {
    final queryParams = {
      'industry': industry,
      'page': page.toString(),
      'country': country,
      'showAll': showAll.toString(),
    };

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final (res, code) = await _api.get('/business?$queryString');

    if (code == 200 && res.data != null) {
      final list = (res.data['data'] as List<dynamic>)
          .map((e) => BusinessItem.fromJson(e as Map<String, dynamic>))
          .toList();
      return Ok(list);
    }

    return Err('Failed to load business', code: code);
  }
}
