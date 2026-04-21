class AdminTrainingRegistrationModel {
  final int id;
  final String name;
  final String email;
  final String attendanceStatus;

  AdminTrainingRegistrationModel({
    required this.id,
    required this.name,
    required this.email,
    required this.attendanceStatus,
  });

  factory AdminTrainingRegistrationModel.fromJson(Map<String, dynamic> json) {
    return AdminTrainingRegistrationModel(
      id: json["id"],
      name: json["full_name"] ??
          json["user"]?["display_name"] ??
          "N/A",
      email: json["email"] ??
          json["user"]?["email"] ??
          "N/A",
      attendanceStatus: json["attendance_status"] ?? "PENDING",
    );
  }
}

class TrainingRegistrationResponse {
  final List<AdminTrainingRegistrationModel> users;

  TrainingRegistrationResponse({required this.users});

  factory TrainingRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return TrainingRegistrationResponse(
      users: (json["registered_users"] as List)
          .map((e) => AdminTrainingRegistrationModel.fromJson(e))
          .toList(),
    );
  }
}