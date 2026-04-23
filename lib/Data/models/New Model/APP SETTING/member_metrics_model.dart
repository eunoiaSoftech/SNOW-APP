class MemberMetrics {
  final int id;
  final String name;
  final String email;
  final String businessName;
  final String category;
  final String city;

  final int giveCount;
  final int receiveCount;
  final double businessBooked;
  final double businessGiven;
  final int testimonialCount;

  MemberMetrics({
    required this.id,
    required this.name,
    required this.email,
    required this.businessName,
    required this.category,
    required this.city,
    required this.giveCount,
    required this.receiveCount,
    required this.businessBooked,
    required this.businessGiven,
    required this.testimonialCount,
  });

  factory MemberMetrics.fromJson(Map<String, dynamic> json) {
    final metrics = json['metrics'];

    int sum(Map m) =>
        (m['sfg'] ?? 0) +
        (m['sbog'] ?? 0) +
        (m['sbol'] ?? 0) +
        (m['smu'] ?? 0);

    return MemberMetrics(
      id: json['id'],
      name: json['display_name'] ?? '',
      email: json['email'] ?? '',
      businessName: json['business']?['name'] ?? '',
      category: json['business']?['category'] ?? '',
      city: json['business']?['city'] ?? '',
      giveCount: sum(metrics['give']),
      receiveCount: sum(metrics['receive']),
      businessBooked:
          double.tryParse(metrics['business_booked_amount'] ?? "0") ?? 0,
      businessGiven:
          double.tryParse(metrics['business_given_amount'] ?? "0") ?? 0,
      testimonialCount: metrics['testimonial_count'] ?? 0,
    );
  }
}