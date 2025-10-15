class LocationData {
  final bool success;
  final int count;
  final List<Location> locations;

  LocationData({
    required this.success,
    required this.count,
    required this.locations,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      locations:
          (json['locations'] as List<dynamic>?)
              ?.map((e) => Location.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Location {
  final String country;
  final String countryCode;
  final String timeZone;
  final List<Zone> zones;

  Location({
    required this.country,
    required this.countryCode,
    required this.timeZone,
    required this.zones,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      country: json['country'] ?? '',
      countryCode: json['country_code'] ?? '',
      timeZone: json['time_zone'] ?? '',
      zones:
          (json['zones'] as List<dynamic>?)
              ?.map((e) => Zone.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Zone {
  final String zone;
  final List<State> states;

  Zone({required this.zone, required this.states});

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      zone: json['zone'] ?? '',
      states:
          (json['states'] as List<dynamic>?)
              ?.map((e) => State.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class State {
  final String state;
  final List<String> cities;

  State({required this.state, required this.cities});

  factory State.fromJson(Map<String, dynamic> json) {
    return State(
      state: json['state'] ?? '',
      cities:
          (json['cities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
