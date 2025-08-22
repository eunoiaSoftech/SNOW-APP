class MeetupResponse {
  final bool success;
  final String message;
  final int? meetupId;

  MeetupResponse({
    required this.success,
    required this.message,
    this.meetupId,
  });

  factory MeetupResponse.fromJson(Map<String, dynamic> json) {
    return MeetupResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      meetupId: json['meetup_id'],
    );
  }
}
