class Contact {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String type;
  final String? company;
  final DateTime createdDate;

  Contact({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    required this.type,
    this.company,
    required this.createdDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'type': type,
      'company': company,
      'created_date': createdDate.toIso8601String(),
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      type: map['type'],
      company: map['company'],
      createdDate: DateTime.parse(map['created_date']),
    );
  }
}
