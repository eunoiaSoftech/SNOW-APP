import 'package:meta/meta.dart';

class BusinessItem {
  final int id;
  final String email;
  final String fullName;
  final String displayName;
  final DateTime registeredDate;
  final String status;
  final BusinessDetails business;

  BusinessItem({
    required this.id,
    required this.email,
    required this.fullName,
    required this.displayName,
    required this.registeredDate,
    required this.status,
    required this.business,
  });

  factory BusinessItem.fromJson(Map<String, dynamic> json) {
    return BusinessItem(
      id: json['id'] as int,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      displayName: json['display_name'] as String,
      registeredDate: DateTime.parse(json['registered_date'] as String),
      status: json['status'] as String,
      business: BusinessDetails.fromJson(json['business'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'display_name': displayName,
        'registered_date': registeredDate.toIso8601String(),
        'status': status,
        'business': business.toJson(),
      };
}

class BusinessDetails {
  final String? name;
  final String? category;
  final String? contact;
  final String? country;
  final String? zone;
  final String? city;
  final String? website;
  final String? gstNo;

  BusinessDetails({
    this.name,
    this.category,
    this.contact,
    this.country,
    this.zone,
    this.city,
    this.website,
    this.gstNo,
  });

  factory BusinessDetails.fromJson(Map<String, dynamic> json) {
    return BusinessDetails(
      name: json['name'] as String?,
      category: json['category'] as String?,
      contact: json['contact'] as String?,
      country: json['country'] as String?,
      zone: json['zone'] as String?,
      city: json['city'] as String?,
      website: json['website'] as String?,
      gstNo: json['gst_no'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        'contact': contact,
        'country': country,
        'zone': zone,
        'city': city,
        'website': website,
        'gst_no': gstNo,
      };
}
