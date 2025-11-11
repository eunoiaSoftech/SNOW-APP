class IglooAssignment {
  final int userId;
  final int userTypeId;
  final int assignedBy;
  final DateTime assignedAt;

  const IglooAssignment({
    required this.userId,
    required this.userTypeId,
    required this.assignedBy,
    required this.assignedAt,
  });

  factory IglooAssignment.fromJson(Map<String, dynamic> json) => IglooAssignment(
        userId: _parseInt(json['user_id']),
        userTypeId: _parseInt(json['user_type_id']),
        assignedBy: _parseInt(json['assigned_by']),
        assignedAt: DateTime.tryParse(json['assigned_at']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      );
}

class Igloo {
  final int id;
  final String name;
  final int countryId;
  final int zoneId;
  final int stateId;
  final int cityId;
  final String meetingTime;
  final String durationType;
  final String mode;
  final String notes;
  final int createdBy;
  final bool isActive;
  final DateTime createdAt;
  final List<IglooAssignment> assignments;
  final String? countryName;
  final String? zoneName;
  final String? stateName;
  final String? cityName;

  const Igloo({
    required this.id,
    required this.name,
    required this.countryId,
    required this.zoneId,
    required this.stateId,
    required this.cityId,
    required this.meetingTime,
    required this.durationType,
    required this.mode,
    required this.notes,
    required this.createdBy,
    required this.isActive,
    required this.createdAt,
    required this.assignments,
    this.countryName,
    this.zoneName,
    this.stateName,
    this.cityName,
  });

  factory Igloo.fromJson(Map<String, dynamic> json) => Igloo(
        id: _parseInt(json['id']),
        name: json['name']?.toString() ?? '',
        countryId: _parseInt(json['country_id']),
        zoneId: _parseInt(json['zone_id']),
        stateId: _parseInt(json['state_id']),
        cityId: _parseInt(json['city_id']),
        meetingTime: json['meeting_time']?.toString() ?? '',
        durationType: json['duration_type']?.toString() ?? '',
        mode: json['mode']?.toString() ?? '',
        notes: json['notes']?.toString() ?? '',
        createdBy: _parseInt(json['created_by']),
        isActive: json['is_active'].toString() == '1',
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
        assignments: (json['assignments'] as List<dynamic>? ?? [])
            .map((e) => IglooAssignment.fromJson(e as Map<String, dynamic>))
            .toList(),
        countryName: json['country_name']?.toString(),
        zoneName: json['zone_name']?.toString(),
        stateName: json['state_name']?.toString(),
        cityName: json['city_name']?.toString(),
      );
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? 0;
}
