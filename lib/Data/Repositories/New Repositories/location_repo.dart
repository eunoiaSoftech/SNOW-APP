import 'package:snow_app/Data/models/New%20Model/location_data.dart';
import 'package:snow_app/core/api_client.dart';
import 'package:snow_app/core/result.dart';

class LocationRepository {
  final ApiClient _api = ApiClient.create();

  /// Fetch location data (countries, zones, cities)
  Future<Result<LocationData>> fetchLocationData() async {
    print('🌍 LOCATION REPOSITORY - fetchLocationData called');
    print('🎯 Making API call to: /auth/location-data');

    try {
      final (res, code) = await _api.get('/auth/location-data');

      print('📊 Location API Response Code: $code');
      print('📦 Location API Response Data: ${res.data}');

      if (code == 200 && res.data != null) {
        final locationData = LocationData.fromJson(res.data);
        print('✅ Successfully parsed location data');
        print(
          '   - Countries: ${locationData.locations.map((l) => l.country).toList()}',
        );
        print('   - Total locations: ${locationData.locations.length}');
        return Ok(locationData);
      }

      print('❌ Failed to load location data - Code: $code, Data: ${res.data}');
      return Err('Failed to load location data', code: code);
    } catch (e) {
      print('💥 Error fetching location data: $e');
      return Err('Error fetching location data: $e', code: 500);
    }
  }

  /// Get all countries from location data
  List<String> getCountries(LocationData locationData) {
    return locationData.locations
        .map((location) => location.country)
        .toSet()
        .toList()
      ..sort();
  }

  /// Get zones for a specific country
  List<String> getZonesForCountry(LocationData locationData, String country) {
    final location = locationData.locations.firstWhere(
      (loc) => loc.country == country,
      orElse: () =>
          Location(country: '', countryCode: '', timeZone: '', zones: []),
    );
    return location.zones.map((zone) => zone.zone).toSet().toList()..sort();
  }

  /// Get cities for a specific country and zone
  List<String> getCitiesForCountryAndZone(
    LocationData locationData,
    String country,
    String zone,
  ) {
    final location = locationData.locations.firstWhere(
      (loc) => loc.country == country,
      orElse: () =>
          Location(country: '', countryCode: '', timeZone: '', zones: []),
    );

    final zoneData = location.zones.firstWhere(
      (z) => z.zone == zone,
      orElse: () => Zone(zone: '', states: []),
    );

    final cities = <String>[];
    for (final state in zoneData.states) {
      cities.addAll(state.cities);
    }
    return cities.toSet().toList()..sort();
  }
}
