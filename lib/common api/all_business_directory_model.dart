// all_business_directory_model.dart

class BusinessDirectoryResponse {
  final bool success;
  final int count;
  final List<BusinessDirectoryItem> data;

  BusinessDirectoryResponse({
    required this.success,
    required this.count,
    required this.data,
  });

  factory BusinessDirectoryResponse.fromJson(Map<String, dynamic> json) {
    return BusinessDirectoryResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => BusinessDirectoryItem.fromJson(e))
          .toList(),
    );
  }
}

class BusinessDirectoryItem {
  final int id;
  final int userId;
  final String userType;
  final String status;
  final DirectoryBusinessData data;
  final int? approvedBy;
  final String? approvedAt;
  final String? createdAt;
  final String? updatedAt;
  final DirectoryUser user;

  BusinessDirectoryItem({
    required this.id,
    required this.userId,
    required this.userType,
    required this.status,
    required this.data,
    this.approvedBy,
    this.approvedAt,
    this.createdAt,
    this.updatedAt,
    required this.user,
  });

  factory BusinessDirectoryItem.fromJson(Map<String, dynamic> json) {
    return BusinessDirectoryItem(
      id: json['id'],
      userId: json['user_id'],
      userType: json['user_type'] ?? '',
      status: json['status'] ?? '',
      data: DirectoryBusinessData.fromJson(json['data'] ?? {}),
      approvedBy: json['approved_by'],
      approvedAt: json['approved_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      user: DirectoryUser.fromJson(json['user'] ?? {}),
    );
  }
}

class DirectoryBusinessData {
  final String? fullName;
  final String? businessName;
  final String? businessCategory;
  final String? businessType;
  final int? yearsInBusiness;
  final String? contact;
  final dynamic country;
  final dynamic zone;
  final dynamic state;
  final dynamic city;
  final String? email;
  final String? gst;
  final String? website;
  final int? paymentDone;
  final String? wantToJoin;
  final String? linkedinId;
  final String? facebookId;
  final String? instagramId;
  final String? companyDescription;

  DirectoryBusinessData({
    this.fullName,
    this.businessName,
    this.businessCategory,
    this.businessType,
    this.yearsInBusiness,
    this.contact,
    this.country,
    this.zone,
    this.state,
    this.city,
    this.email,
    this.gst,
    this.website,
    this.paymentDone,
    this.wantToJoin,
    this.linkedinId,
    this.facebookId,
    this.instagramId,
    this.companyDescription,
  });

  factory DirectoryBusinessData.fromJson(Map<String, dynamic> json) {
    return DirectoryBusinessData(
      fullName: json['full_name'],
      businessName: json['business_name'],
      businessCategory: json['business_category'],
      businessType: json['business_type'],
      yearsInBusiness: json['years_in_business'],
      contact: json['contact'],
      country: json['country'],
      zone: json['zone'],
      state: json['state'],
      city: json['city'],
      email: json['email'],
      gst: json['gst'],
      website: json['website'],
      paymentDone: json['payment_done'],
      wantToJoin: json['want_to_join'],
      linkedinId: json['linkedin_id'],
      facebookId: json['facebook_id'],
      instagramId: json['instagram_id'],
      companyDescription: json['company_description'],
    );
  }
}

class DirectoryUser {
  final int id;
  final String displayName;
  final String email;
  final String activeUserType;
  final int activeUserTypeId;

  DirectoryUser({
    required this.id,
    required this.displayName,
    required this.email,
    required this.activeUserType,
    required this.activeUserTypeId,
  });

  factory DirectoryUser.fromJson(Map<String, dynamic> json) {
    return DirectoryUser(
      id: json['id'] ?? 0,
      displayName: json['display_name'] ?? '',
      email: json['email'] ?? '',
      activeUserType: json['active_user_type'] ?? '',
      activeUserTypeId: json['active_user_type_id'] ?? 0,
    );
  }
}
