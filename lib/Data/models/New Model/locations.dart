class StateData {
  final String state;
  final List<String> cities;

  StateData({required this.state, required this.cities});

  factory StateData.fromJson(Map<String, dynamic> json) {
    return StateData(
      state: json['state'] as String,
      // Safely map the list of dynamic objects to a list of strings
      cities: (json['cities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

/// Data Model for a Zone (containing states)
class ZoneData {
  final String zone;
  final List<StateData> states;

  ZoneData({required this.zone, required this.states});

  factory ZoneData.fromJson(Map<String, dynamic> json) {
    return ZoneData(
      zone: json['zone'] as String,
      // Map the list of dynamic objects (which are state JSON maps) to StateData objects
      states: (json['states'] as List<dynamic>?)
              ?.map((e) => StateData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Data Model for a Country/Location (containing zones)
class LocationData {
  final String country;
  final String countryCode;
  final String timeZone;
  final List<ZoneData> zones;

  LocationData({
    required this.country,
    required this.countryCode,
    required this.timeZone,
    required this.zones,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      country: json['country'] as String,
      countryCode: json['country_code'] as String,
      timeZone: json['time_zone'] as String,
      // Map the list of dynamic objects (which are zone JSON maps) to ZoneData objects
      zones: (json['zones'] as List<dynamic>?)
              ?.map((e) => ZoneData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Root Response Model
class LocationResponse {
  final bool success;
  final int count;
  final List<LocationData> locations;

  LocationResponse({
    required this.success,
    required this.count,
    required this.locations,
  });

  factory LocationResponse.fromJson(Map<String, dynamic> json) {
    return LocationResponse(
      success: json['success'] as bool,
      count: json['count'] as int,
      // Map the list of dynamic objects (which are country JSON maps) to LocationData objects
      locations: (json['locations'] as List<dynamic>?)
              ?.map((e) => LocationData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
