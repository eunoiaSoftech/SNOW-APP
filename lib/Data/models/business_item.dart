class CustomBusinessItem {
  String? id;
  String? email;
  String? registeredDate;
  String? fullName;
  String? displayName;
  Business? business;

  CustomBusinessItem(
      {this.id,
        this.email,
        this.registeredDate,
        this.fullName,
        this.displayName,
        this.business});

  CustomBusinessItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    registeredDate = json['registered_date'];
    fullName = json['full_name'];
    displayName = json['display_name'];
    business = json['business'] != null
        ? new Business.fromJson(json['business'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['email'] = this.email;
    data['registered_date'] = this.registeredDate;
    data['full_name'] = this.fullName;
    data['display_name'] = this.displayName;
    if (this.business != null) {
      data['business'] = this.business!.toJson();
    }
    return data;
  }
}

class Business {
  String? name;
  String? category;
  String? contact;
  String? city;
  String? website;
  String? gstNo;

  Business(
      {this.name,
        this.category,
        this.contact,
        this.city,
        this.website,
        this.gstNo});

  Business.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    category = json['category'];
    contact = json['contact'];
    city = json['city'];
    website = json['website'];
    gstNo = json['gst_no'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['category'] = this.category;
    data['contact'] = this.contact;
    data['city'] = this.city;
    data['website'] = this.website;
    data['gst_no'] = this.gstNo;
    return data;
  }
}
