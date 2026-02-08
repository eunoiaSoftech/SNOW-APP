import 'package:snow_app/Data/models/New%20Model/location_data123.dart';
import 'package:snow_app/core/api_client.dart';
import 'package:snow_app/core/result.dart';

class LocationRepository {
  final ApiClient _api = ApiClient.create();

  /// FIXED: Correct API call using router.php?endpoint=location/list
  Future<Result<LocationData>> fetchLocationData() async {
    print('🌍 LOCATION REPOSITORY - fetchLocationData called');

    final uri = Uri.parse(
      'https://mediumvioletred-chough-398772.hostingersite.com/api/v1/router.php',
    ).replace(queryParameters: {
      'endpoint': 'location/list',
    });

    print('🎯 Making API call to: $uri');

    try {
      final (res, code) = await _api.getUri(uri);

      print('📊 Location API Response Code: $code');
      print('📦 Location API Response Data: ${res.data}');

      if (code == 200 && res.data != null) {
        final locationData = LocationData.fromJson(res.data);

        print('✅ Successfully parsed location data');
        print('   - Countries: ${locationData.countries.map((c) => c.name).toList()}');
        print('   - Total countries: ${locationData.countries.length}');

        return Ok(locationData);
      }

      print('❌ Failed to load location data - Code: $code, Data: ${res.data}');
      return Err('Failed to load location data', code: code);
    } catch (e) {
      print('💥 Error fetching location data: $e');
      return Err('Error fetching location data: $e', code: 500);
    }
  }

  /// Get all countries
  List<String> getCountries(LocationData data) {
    return data.countries.map((c) => c.name).toList()..sort();
  }

  /// Get zones for a selected country
  List<String> getZonesForCountry(LocationData data, String country) {
    final selected = data.countries.firstWhere(
      (c) => c.name == country,
      orElse: () => Country(id: 0, name: '', code: '', zones: []),
    );

    return selected.zones.map((z) => z.name).toList()..sort();
  }

  /// Get cities for a selected country + zone
  List<String> getCitiesForCountryAndZone(
      LocationData data, String country, String zone) {
    final selectedCountry = data.countries.firstWhere(
      (c) => c.name == country,
      orElse: () => Country(id: 0, name: '', code: '', zones: []),
    );

    final selectedZone = selectedCountry.zones.firstWhere(
      (z) => z.name == zone,
      orElse: () => Zone(id: 0, name: '', code: '', states: []),
    );

    final cities = <String>[];
    for (final st in selectedZone.states) {
      cities.addAll(st.cities.map((c) => c.name));
    }

    return cities..sort();
  }
}
