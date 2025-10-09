class SbogRequest {
  final String receiverBusinessId;
  final String toMember;
  final String referral;
  final String telephone;
  final String email;
  final String level;
  final String comments;

  SbogRequest({
    required this.receiverBusinessId,
    required this.toMember,
    required this.referral,
    required this.telephone,
    required this.email,
    required this.level,
    required this.comments,
  });

  Map<String, dynamic> toJson() => {
        "receiver_business_id": receiverBusinessId,
        "to_member": toMember,
        "referral": referral,
        "telephone": telephone,
        "email": email,
        "level": level,
        "comments": comments,
      };
}

class SbogResponse {
  final bool success;
  final String message;
  final int? recordId;

  SbogResponse({
    required this.success,
    required this.message,
    this.recordId,
  });

  factory SbogResponse.fromJson(Map<String, dynamic> json) => SbogResponse(
        success: json["success"] ?? false,
        message: json["message"] ?? '',
        recordId: json["record_id"],
      );
}
