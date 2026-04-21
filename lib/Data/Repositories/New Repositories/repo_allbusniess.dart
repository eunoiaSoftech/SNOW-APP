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
    String zone = '',
    String city = '',
    String igloo = '',
    String search = '',
    bool showAll = true,
  }) async {
    print('🏢 BUSINESS REPOSITORY - fetchBusiness called');
    print('📋 Input Parameters:');
    print('   - industry: "$industry"');
    print('   - page: $page');
    print('   - country: "$country"');
    print('   - zone: "$zone"');
    print('   - city: "$city"');
    print('   - igloo: "$igloo"');
    print('   - search: "$search"');
    print('   - showAll: $showAll');

    final queryParams = <String, String>{
      'industry': industry,
      'page': page.toString(),
      'is_active': '1',
    };
    // Only add showAll if it's true, otherwise omit it to avoid passing false
    if (showAll) {
      queryParams['showAll'] = 'true';
    }

    // Add filter parameters only if they have values
    if (country.isNotEmpty) {
      queryParams['country'] = country;
    }
    if (zone.isNotEmpty) {
      queryParams['zone'] = zone;
    }
    if (city.isNotEmpty) {
      queryParams['city'] = city;
    }
    if (igloo.isNotEmpty) {
      queryParams['igloo'] = igloo;
    }
    if (search.isNotEmpty) {
      queryParams['search'] = search;
    }

    print('📦 Final Query Parameters: $queryParams');

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    print('🔗 Final Query String: $queryString');
    print('🎯 Making API call to: /business?$queryString');

    // final (res, code) = await _api.get('/business?$queryString');
    final (res, code) = await _api.get('?endpoint=business&$queryString');
    print('📊 API Response Code: $code');
    print('📦 API Response Data: ${res.data}');

    if (code == 200 && res.data != null) {
      final list = (res.data['data'] as List<dynamic>)
          .map((e) => BusinessItem.fromJson(e as Map<String, dynamic>))
          .toList();
      print('✅ Successfully parsed ${list.length} business items');
      return Ok(list);
    }

    print('❌ Failed to load business - Code: $code, Data: ${res.data}');
    return Err('Failed to load business', code: code);
  }
}
