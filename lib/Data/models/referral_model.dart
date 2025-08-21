class Referral {
  final String id;
  final String senderId;
  final String receiverId;
  final String leadName;
  final String message;
  final String status;
  final String createdAt;

  Referral({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.leadName,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory Referral.fromJson(Map<String, dynamic> json) {
    return Referral(
      id: json['id'] ?? '',
      senderId: json['sender_id'] ?? '',
      receiverId: json['receiver_id'] ?? '',
      leadName: json['lead_name'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}

class MyReferralsResponse {
  final bool success;
  final List<Referral> referrals;

  MyReferralsResponse({
    required this.success,
    required this.referrals,
  });

  factory MyReferralsResponse.fromJson(Map<String, dynamic> json) {
    return MyReferralsResponse(
      success: json['success'] ?? false,
      referrals: (json['referrals'] as List<dynamic>?)
              ?.map((e) => Referral.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}