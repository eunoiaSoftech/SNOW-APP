class MeetupItem {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String venueName;
  final String venueAddress;
  final String venueCity;
  final String venueState;
  final String venueCountry;
  final String venueLatitude;
  final String venueLongitude;
  final String date;
  final String capacity;
  final String isPaid;
  final String price;
  final String contactName;
  final String contactEmail;
  final String contactPhone;
  final String createdAt;

  MeetupItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.venueName,
    required this.venueAddress,
    required this.venueCity,
    required this.venueState,
    required this.venueCountry,
    required this.venueLatitude,
    required this.venueLongitude,
    required this.date,
    required this.capacity,
    required this.isPaid,
    required this.price,
    required this.contactName,
    required this.contactEmail,
    required this.contactPhone,
    required this.createdAt,
  });

  factory MeetupItem.fromJson(Map<String, dynamic> json) {
    return MeetupItem(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      venueName: json['venue_name'] ?? '',
      venueAddress: json['venue_address'] ?? '',
      venueCity: json['venue_city'] ?? '',
      venueState: json['venue_state'] ?? '',
      venueCountry: json['venue_country'] ?? '',
      venueLatitude: json['venue_latitude'] ?? '',
      venueLongitude: json['venue_longitude'] ?? '',
      date: json['date'] ?? '',
      capacity: json['capacity'] ?? '',
      isPaid: json['is_paid'] ?? '',
      price: json['price'] ?? '',
      contactName: json['contact_name'] ?? '',
      contactEmail: json['contact_email'] ?? '',
      contactPhone: json['contact_phone'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
class MeetupListResponse {
  final bool success;
  final List<MeetupItem> meetups;

  MeetupListResponse({required this.success, required this.meetups});

  factory MeetupListResponse.fromJson(Map<String, dynamic> json) {
    return MeetupListResponse(
      success: json['success'] ?? false,
      meetups: (json['meetups'] as List<dynamic>?)
              ?.map((e) => MeetupItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}
