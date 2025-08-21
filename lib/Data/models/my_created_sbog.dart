class MyCreatedSbog {
  bool? success;
  List<Referrals>? referrals;

  MyCreatedSbog({this.success, this.referrals});

  MyCreatedSbog.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['referrals'] != null) {
      referrals = <Referrals>[];
      json['referrals'].forEach((v) {
        referrals!.add(new Referrals.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.referrals != null) {
      data['referrals'] = this.referrals!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Referrals {
  String? id;
  String? senderId;
  String? receiverId;
  String? leadName;
  String? message;
  String? status;
  String? createdAt;

  Referrals(
      {this.id,
        this.senderId,
        this.receiverId,
        this.leadName,
        this.message,
        this.status,
        this.createdAt});

  Referrals.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    senderId = json['sender_id'];
    receiverId = json['receiver_id'];
    leadName = json['lead_name'];
    message = json['message'];
    status = json['status'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['sender_id'] = this.senderId;
    data['receiver_id'] = this.receiverId;
    data['lead_name'] = this.leadName;
    data['message'] = this.message;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    return data;
  }
}
