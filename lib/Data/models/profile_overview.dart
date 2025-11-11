class ProfileOverview {
  final ProfileUser user;
  final List<UserTypeMembership> userTypes;
  final List<ModuleAccess> modules;
  final List<IglooMembership> igloos;

  const ProfileOverview({
    required this.user,
    required this.userTypes,
    required this.modules,
    required this.igloos,
  });

  factory ProfileOverview.fromJson(Map<String, dynamic> json) {
    return ProfileOverview(
      user: ProfileUser.fromJson(json['user'] as Map<String, dynamic>),
      userTypes: (json['user_types'] as List<dynamic>? ?? [])
          .map((e) => UserTypeMembership.fromJson(e as Map<String, dynamic>))
          .toList(),
      modules: (json['modules'] as List<dynamic>? ?? [])
          .map((e) => ModuleAccess.fromJson(e as Map<String, dynamic>))
          .toList(),
      igloos: (json['igloos'] as List<dynamic>? ?? [])
          .map((e) => IglooMembership.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProfileUser {
  final int id;
  final String email;
  final String fullName;
  final bool isAdmin;
  final int? activeUserTypeId;
  final String? activeUserType;

  const ProfileUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.isAdmin,
    this.activeUserTypeId,
    this.activeUserType,
  });

  factory ProfileUser.fromJson(Map<String, dynamic> json) => ProfileUser(
        id: _parseInt(json['id']),
        email: json['email']?.toString() ?? '',
        fullName: json['full_name']?.toString() ?? '',
        isAdmin: json['is_admin'] == true,
        activeUserTypeId: _parseNullableInt(json['active_user_type_id']),
        activeUserType: json['active_user_type']?.toString(),
      );
}

class UserTypeMembership {
  final int id;
  final String userType;
  final String status;
  final Map<String, dynamic> data;
  final int? approvedBy;
  final DateTime? approvedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserTypeMembership({
    required this.id,
    required this.userType,
    required this.status,
    required this.data,
    this.approvedBy,
    this.approvedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory UserTypeMembership.fromJson(Map<String, dynamic> json) => UserTypeMembership(
        id: _parseInt(json['id']),
        userType: json['user_type']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        data: (json['data'] as Map?)?.map((key, value) => MapEntry(key.toString(), value)) ?? const {},
        approvedBy: _parseNullableInt(json['approved_by']),
        approvedAt: json['approved_at'] != null
            ? DateTime.tryParse(json['approved_at'].toString())
            : null,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'].toString())
            : null,
      );
}

class ModuleAccess {
  final int id;
  final String slug;
  final String name;
  final String description;
  final bool isActive;
  final int createdBy;
  final DateTime createdAt;
  final bool isEnabled;

  const ModuleAccess({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.isEnabled,
  });

  factory ModuleAccess.fromJson(Map<String, dynamic> json) => ModuleAccess(
        id: _parseInt(json['id']),
        slug: json['slug']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        isActive: json['is_active'].toString() == '1' || json['is_active'] == true,
        createdBy: _parseInt(json['created_by']),
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        isEnabled: json['is_enabled'].toString() == '1' || json['is_enabled'] == true,
      );
}

class IglooMembership {
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
  final int? userTypeId;

  const IglooMembership({
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
    this.userTypeId,
  });

  factory IglooMembership.fromJson(Map<String, dynamic> json) => IglooMembership(
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
        isActive: json['is_active'].toString() == '1' || json['is_active'] == true,
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        userTypeId: _parseNullableInt(json['user_type_id']),
      );
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? 0;
}

int? _parseNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}
