class AdminCountry {
  final int id;
  final String name;

  AdminCountry({required this.id, required this.name});

  factory AdminCountry.fromJson(Map<String, dynamic> json) {
    return AdminCountry(id: json['id'], name: json['name']);
  }
}

class AdminState {
  final int id;
  final String name;
  final int countryId;

  AdminState({required this.id, required this.name, required this.countryId});

  factory AdminState.fromJson(Map<String, dynamic> json) {
    return AdminState(
      id: json['id'],
      name: json['name'],
      countryId: json['country_id'],
    );
  }
}

class AdminCity {
  final int id;
  final String name;
  final int countryId;
  final int stateId;

  AdminCity({
    required this.id,
    required this.name,
    required this.countryId,
    required this.stateId,
  });

  factory AdminCity.fromJson(Map<String, dynamic> json) {
    return AdminCity(
      id: json['id'],
      name: json['name'],
      countryId: json['country_id'],
      stateId: json['state_id'],
    );
  }
}

class AdminZone {
  final int id;
  final String name;
  final int parentId;

  AdminZone({required this.id, required this.name, required this.parentId});

  factory AdminZone.fromJson(Map<String, dynamic> json) {
    return AdminZone(
      id: json['id'],
      name: json['name'],
      parentId: json['parent_id'],
    );
  }
}
