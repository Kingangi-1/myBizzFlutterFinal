class BusinessProfile {
  final String id;
  String businessName;
  String? businessType;
  String? address;
  String? phone;
  String? email;
  String? website;
  String? taxNumber;
  String? logoPath;
  String currency;
  DateTime createdAt;
  DateTime updatedAt;

  BusinessProfile({
    required this.id,
    required this.businessName,
    this.businessType,
    this.address,
    this.phone,
    this.email,
    this.website,
    this.taxNumber,
    this.logoPath,
    this.currency = 'KES',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'businessName': businessName,
      'businessType': businessType,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'taxNumber': taxNumber,
      'logoPath': logoPath,
      'currency': currency,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static BusinessProfile fromMap(Map<String, dynamic> map) {
    return BusinessProfile(
      id: map['id'],
      businessName: map['businessName'],
      businessType: map['businessType'],
      address: map['address'],
      phone: map['phone'],
      email: map['email'],
      website: map['website'],
      taxNumber: map['taxNumber'],
      logoPath: map['logoPath'],
      currency: map['currency'] ?? 'KES',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  BusinessProfile copyWith({
    String? businessName,
    String? businessType,
    String? address,
    String? phone,
    String? email,
    String? website,
    String? taxNumber,
    String? logoPath,
    String? currency,
  }) {
    return BusinessProfile(
      id: id,
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      taxNumber: taxNumber ?? this.taxNumber,
      logoPath: logoPath ?? this.logoPath,
      currency: currency ?? this.currency,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
