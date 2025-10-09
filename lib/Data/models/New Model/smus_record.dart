// class SmusRecord {
//   final String? id;
//   final String? creatorId;
//   final String? toMember;
//   final String? abstractText;
//   final String? date;
//   final String? collabType;
//   final String? followupDate;
//   final String? mode;
//   final String? createdAt;
//   final String? createdUserId;
//   final String? toBusinessId;

//   SmusRecord({
//     this.id,
//     this.creatorId,
//     this.toMember,
//     this.abstractText,
//     this.date,
//     this.collabType,
//     this.followupDate,
//     this.mode,
//     this.createdAt,
//     this.createdUserId,
//     this.toBusinessId,
//   });

//   factory SmusRecord.fromJson(Map<String, dynamic> json) {
//     return SmusRecord(
//       id: json['id']?.toString(),
//       creatorId: json['creator_id']?.toString(),
//       toMember: json['to_member'],
//       abstractText: json['abstract'],
//       date: json['date'],
//       collabType: json['collab_type']?.toString(),
//       followupDate: json['followup_date'],
//       mode: json['mode'],
//       createdAt: json['created_at'],
//       createdUserId: json['created_user_id']?.toString(),
//       toBusinessId: json['to_business_id']?.toString(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       "id": id,
//       "creator_id": creatorId,
//       "to_member": toMember,
//       "abstract": abstractText,
//       "date": date,
//       "collab_type": collabType,
//       "followup_date": followupDate,
//       "mode": mode,
//       "created_at": createdAt,
//       "created_user_id": createdUserId,
//       "to_business_id": toBusinessId,
//     };
//   }
// }


// lib/Data/models/smus_record_model.dart
class SMUSRecord {
  final String id;
  final String toMember;
  final String abstractText;
  final String date;
  final String collabType;
  final String followupDate;
  final String mode;
  final String createdAt;

  SMUSRecord({
    required this.id,
    required this.toMember,
    required this.abstractText,
    required this.date,
    required this.collabType,
    required this.followupDate,
    required this.mode,
    required this.createdAt,
  });

  factory SMUSRecord.fromJson(Map<String, dynamic> json) {
    return SMUSRecord(
      id: json['id']?.toString() ?? '',
      toMember: json['to_member'] ?? '',
      abstractText: json['abstract'] ?? '',
      date: json['date'] ?? '',
      collabType: json['collab_type']?.toString() ?? '',
      followupDate: json['followup_date'] ?? '',
      mode: json['mode'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
