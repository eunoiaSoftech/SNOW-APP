import 'package:snow_app/Data/models/user.dart';

class ProfileModel {
  final bool success;
  final User? profile;
  final String? registeredDate;

  const ProfileModel({required this.success, this.profile, this.registeredDate});

  factory ProfileModel.fromJson(Map<String, dynamic> j) => ProfileModel(
        success: j['success'] == true,
        profile: j['profile'] != null ? User.fromJson(j['profile']) : null,
        registeredDate: j['profile']?['registered_date']?.toString(),
      );
}