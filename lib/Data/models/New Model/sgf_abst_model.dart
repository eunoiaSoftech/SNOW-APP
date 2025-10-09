import 'package:flutter/foundation.dart';

/// ✅ Giver Business Model
class GiverBusiness {
  final String name;
  final String category;
  final String contact;
  final String city;
  final String website;
  final String gstNo;
  final String status;

  GiverBusiness({
    required this.name,
    required this.category,
    required this.contact,
    required this.city,
    required this.website,
    required this.gstNo,
    required this.status,
  });

  factory GiverBusiness.fromJson(Map<String, dynamic> json) {
    return GiverBusiness(
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      contact: json['contact'] as String? ?? '',
      city: json['city'] as String? ?? '',
      website: json['website'] as String? ?? '',
      gstNo: json['gst_no'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}

/// ✅ Single Record Model (list item in `records`)
class SfgAbsRecord {
  final String id;
  final String createdUserId;
  final String giverBusinessId;
  final String receiverBusinessId;
  final String toMember;
  final String amount;
  final String remarks;
  final String createdAt;
  final GiverBusiness giverBusiness;

  SfgAbsRecord({
    required this.id,
    required this.createdUserId,
    required this.giverBusinessId,
    required this.receiverBusinessId,
    required this.toMember,
    required this.amount,
    required this.remarks,
    required this.createdAt,
    required this.giverBusiness,
  });

  factory SfgAbsRecord.fromJson(Map<String, dynamic> json) {
    return SfgAbsRecord(
      id: json['id'] as String? ?? '',
      createdUserId: json['created_user_id'] as String? ?? '',
      giverBusinessId: json['giver_business_id'] as String? ?? '',
      receiverBusinessId: json['receiver_business_id'] as String? ?? '',
      toMember: json['to_member'] as String? ?? '',
      amount: json['amount'] as String? ?? '',
      remarks: json['remarks'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      giverBusiness: GiverBusiness.fromJson(
        json['giver_business'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

/// ✅ Filters Model (inside `filters`)
class SfgAbsFilters {
  final String? startDate;
  final String? endDate;
  final int? businessId; // null / int (safe)
  final bool onlyMy;
  final String? query;

  SfgAbsFilters({
    this.startDate,
    this.endDate,
    this.businessId,
    required this.onlyMy,
    this.query,
  });

  factory SfgAbsFilters.fromJson(Map<String, dynamic> json) {
    dynamic rawBusinessId = json['business_id'];
    int? parsedBusinessId;

    /// 🧠 DEBUG — See what backend actually sends
    debugPrint("🔍 FILTER_DEBUG → RAW business_id: '$rawBusinessId' | TYPE: ${rawBusinessId.runtimeType}");

    if (rawBusinessId is int) {
      parsedBusinessId = rawBusinessId;
    } else if (rawBusinessId is String) {
      parsedBusinessId = int.tryParse(rawBusinessId);
    }

    return SfgAbsFilters(
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      businessId: parsedBusinessId,
      onlyMy: json['only_my'] as bool? ?? false,
      query: json['query'] as String?,
    );
  }
}

/// ✅ MAIN Response Model
class SfgAbsResponse {
  final bool success;
  final int count;
  final SfgAbsFilters filters;
  final List<SfgAbsRecord> records;

  SfgAbsResponse({
    required this.success,
    required this.count,
    required this.filters,
    required this.records,
  });

  factory SfgAbsResponse.fromJson(Map<String, dynamic> json) {
    debugPrint("🛠 STEP: Mapping JSON to Model...");

    return SfgAbsResponse(
      success: json['success'] as bool? ?? false,
      count: json['count'] is int
          ? json['count']
          : int.tryParse(json['count'].toString()) ?? 0,
      filters: SfgAbsFilters.fromJson(
        json['filters'] as Map<String, dynamic>? ?? {},
      ),
      records: (json['records'] as List<dynamic>? ?? [])
          .map((e) => SfgAbsRecord.fromJson(e))
          .toList(),
    );
  }
}
