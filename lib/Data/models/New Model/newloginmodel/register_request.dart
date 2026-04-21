class RegisterRequest {
  final String userType;
  final String fullName;
  final String email;
  final String password;
  final String businessName;
  final String businessCategory;
  final String contact;
  final int country;
  final int zone;
  final int state;
  final int city;
  final String companyDescription;
  final int age;

  final String? linkedin;
  final String? facebook;
  final String? instagram;

  RegisterRequest({
    required this.userType,
    required this.fullName,
    required this.email,
    required this.password,
    required this.businessName,
    required this.businessCategory,
    required this.contact,
    required this.country,
    required this.zone,
    required this.state,
    required this.city,
    required this.companyDescription,
    required this.age,
    this.linkedin,
    this.facebook,
    this.instagram,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_type': userType,
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
      'age': age,
      if (linkedin != null) 'linkedin_id': linkedin,
      if (facebook != null) 'facebook_id': facebook,
      if (instagram != null) 'instagram_id': instagram,
    };
  }
}