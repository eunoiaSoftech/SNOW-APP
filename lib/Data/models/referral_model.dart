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
      id: json['id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      receiverId: json['receiver_id']?.toString() ?? '',
      leadName: json['lead_name'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Referral(id: $id, leadName: $leadName, status: $status)';
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
    final received = (json['received_referrals'] ?? []) as List<dynamic>;
    print("🧩 [Model] Parsing received_referrals: count = ${received.length}");

    return MyReferralsResponse(
      success: json['success'] ?? false,
      referrals: received.map((e) => Referral.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
