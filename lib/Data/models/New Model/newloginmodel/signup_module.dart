import 'dart:io';

class SignupModule {
  String fullName = '';
  String email = '';
  String password = '';
  String businessName = '';
  String contact = '';
  String companyDescription = '';
  String? linkedin;
  String? facebook;
  String? instagram;
  String iglooId = '';

  int? country;
  int? zone;
  int? state;
  int? city;

  String? businessCategory;

  File? aadharFile;
  File? userPhoto;

  Map<String, dynamic> toBody(String userType) {
    final body = {
      'user_type': userType,
      'age': 25, // 🔥 REQUIRED FIX
      'full_name': fullName,
      'email': email,
      'password': password,
      'business_name': businessName,
      'business_category': businessCategory,
      'contact': contact,
      'country': country,
      'zone': zone,
      'state': state,
      'city': city,
      'company_description': companyDescription,
      'igloo_id': iglooId,
    };

    if (linkedin != null) body['linkedin_id'] = linkedin;
    if (facebook != null) body['facebook_id'] = facebook;
    if (instagram != null) body['instagram_id'] = instagram;

    print("📦 FINAL BODY => $body");

    return body;
  }
}