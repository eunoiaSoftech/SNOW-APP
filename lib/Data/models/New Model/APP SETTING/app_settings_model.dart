class AppSettingsModel {
  final bool maintenanceMode;
  final bool forceUpdate;
  final bool forceLogout;
  final String appVersion;
  final String minRequiredVersion;
  final String updateMessage;
  final String maintenanceMessage;
  final String platform;

  AppSettingsModel({
    required this.maintenanceMode,
    required this.forceUpdate,
    required this.forceLogout,
    required this.appVersion,
    required this.minRequiredVersion,
    required this.updateMessage,
    required this.maintenanceMessage,
    required this.platform,
  });

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    bool _toBool(dynamic value) {
      if (value == true || value == 1 || value == "1") return true;
      return false;
    }

    return AppSettingsModel(
      maintenanceMode: _toBool(json['maintenance_mode']),
      forceUpdate: _toBool(json['force_update']),
      forceLogout: _toBool(json['force_logout']),
      appVersion: json['app_version']?.toString() ?? '',
      minRequiredVersion: json['min_required_version']?.toString() ?? '',
      updateMessage: json['update_message']?.toString() ?? '',
      maintenanceMessage: json['maintenance_message']?.toString() ?? '',
      platform: json['platform']?.toString() ?? '',
    );
  }
}
