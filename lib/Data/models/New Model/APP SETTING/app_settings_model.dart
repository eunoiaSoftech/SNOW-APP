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
    return AppSettingsModel(
      maintenanceMode: json['maintenance_mode'] ?? false,
      forceUpdate: json['force_update'] ?? false,
      forceLogout: json['force_logout'] ?? false,
      appVersion: json['app_version'] ?? '',
      minRequiredVersion: json['min_required_version'] ?? '',
      updateMessage: json['update_message'] ?? '',
      maintenanceMessage: json['maintenance_message'] ?? '',
      platform: json['platform'] ?? '',
    );
  }
}
