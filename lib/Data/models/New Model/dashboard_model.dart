class DashboardModel {
  final int smu;
  final int opportunities;
  final int trainings;
  final int snowPoints;

  DashboardModel({
    required this.smu,
    required this.opportunities,
    required this.trainings,
    required this.snowPoints,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final metrics = json['metrics'];

    return DashboardModel(
      smu: metrics['give']['smu'] ?? 0,
      opportunities: metrics['give']['sfg'] ?? 0,
      trainings: metrics['give']['sbg'] ?? 0,
      snowPoints: metrics['receive']['smu'] ?? 0,
    );
  }
}