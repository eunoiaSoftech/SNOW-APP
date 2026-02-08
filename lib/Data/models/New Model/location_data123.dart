class LocationData {
  final bool success;
  final List<Country> countries;

  LocationData({
    required this.success,
    required this.countries,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      success: json['success'] ?? false,
      countries: (json['data'] as List<dynamic>? ?? [])
          .map((e) => Country.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Country {
  final int id;
  final String name;
  final String code;
  final List<Zone> zones;

  Country({
    required this.id,
    required this.name,
    required this.code,
    required this.zones,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      zones: (json['zones'] as List<dynamic>? ?? [])
          .map((e) => Zone.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Zone {
  final int id;
  final String name;
  final String code;
  final List<StateData> states;

  Zone({
    required this.id,
    required this.name,
    required this.code,
    required this.states,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      states: (json['states'] as List<dynamic>? ?? [])
          .map((e) => StateData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class StateData {
  final int id;
  final String name;
  final String code;
  final List<City> cities;

  StateData({
    required this.id,
    required this.name,
    required this.code,
    required this.cities,
  });

  factory StateData.fromJson(Map<String, dynamic> json) {
    return StateData(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      cities: (json['cities'] as List<dynamic>? ?? [])
          .map((e) => City.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class City {
  final int id;
  final String name;
  final String code;

  City({
    required this.id,
    required this.name,
    required this.code,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }
}
