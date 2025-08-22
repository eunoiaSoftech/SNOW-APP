class Business {
  final String? name;
  final String? category;
  final String? contact;
  final String? city;
  final String? website;
  final String? gstNo;

  Business({this.name, this.category, this.contact, this.city, this.website, this.gstNo});

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      name: json['name'],
      category: json['category'],
      contact: json['contact'],
      city: json['city'],
      website: json['website'],
      gstNo: json['gst_no'],
    );
  }
}

class TopReceiver {
  final String id;
  final String email;
  final String? fullName;
  final String displayName;
  final String registeredDate;
  final Business business;
  final int totalReceived;

  TopReceiver({
    required this.id,
    required this.email,
    this.fullName,
    required this.displayName,
    required this.registeredDate,
    required this.business,
    required this.totalReceived,
  });

  factory TopReceiver.fromJson(Map<String, dynamic> json) {
    return TopReceiver(
      id: json['id'].toString(),
      email: json['email'],
      fullName: json['full_name'],
      displayName: json['display_name'],
      registeredDate: json['registered_date'],
      business: Business.fromJson(json['business']),
      totalReceived: json['total_received'],
    );
  }
}

class TopGiver {
  final int id;
  final String email;
  final String? fullName;
  final String displayName;
  final String registeredDate;
  final Business business;
  final int totalGiven;

  TopGiver({
    required this.id,
    required this.email,
    this.fullName,
    required this.displayName,
    required this.registeredDate,
    required this.business,
    required this.totalGiven,
  });

  factory TopGiver.fromJson(Map<String, dynamic> json) {
    return TopGiver(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      displayName: json['display_name'],
      registeredDate: json['registered_date'],
      business: Business.fromJson(json['business']),
      totalGiven: json['total_given'],
    );
  }
}
