int _parseId(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

class CountryOption {
  final int id;
  final String name;
  final String code;
  final List<ZoneOption> zones;

  const CountryOption({
    required this.id,
    required this.name,
    required this.code,
    required this.zones,
  });

  factory CountryOption.fromJson(Map<String, dynamic> json) => CountryOption(
        id: _parseId(json['id']),
        name: json['name'] ?? '',
        code: json['code'] ?? '',
        zones: (json['zones'] as List<dynamic>? ?? [])
            .map((e) => ZoneOption.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      
}

class ZoneOption {
  final int id;
  final String name;
  final String code;
  final List<StateOption> states;

  const ZoneOption({
    required this.id,
    required this.name,
    required this.code,
    required this.states,
  });

  factory ZoneOption.fromJson(Map<String, dynamic> json) => ZoneOption(
        id: _parseId(json['id']),
        name: json['name'] ?? '',
        code: json['code'] ?? '',
        states: (json['states'] as List<dynamic>? ?? [])
            .map((e) => StateOption.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class StateOption {
  final int id;
  final String name;
  final String code;
  final List<CityOption> cities;

  const StateOption({
    required this.id,
    required this.name,
    required this.code,
    required this.cities,
  });

  factory StateOption.fromJson(Map<String, dynamic> json) => StateOption(
        id: _parseId(json['id']),
        name: json['name'] ?? '',
        code: json['code'] ?? '',
        cities: (json['cities'] as List<dynamic>? ?? [])
            .map((e) => CityOption.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CityOption {
  final int id;
  final String name;
  final String code;

  const CityOption({
    required this.id,
    required this.name,
    required this.code,
  });

  factory CityOption.fromJson(Map<String, dynamic> json) => CityOption(
        id: _parseId(json['id']),
        name: json['name'] ?? '',
        code: json['code'] ?? '',
      );
}

