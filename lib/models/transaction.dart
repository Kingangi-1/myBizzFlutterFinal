class BusinessTransaction {
  final int? id;
  final double amount;
  final String type;
  final String description;
  final DateTime date;
  final String? category; // Category name for backward compatibility
  final String? categoryId; // Add this - reference to Category model
  final bool isCredit;
  final String? contactName;
  final String? contactPhone;
  final String? mpesaReference;

  BusinessTransaction({
    this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
    this.category,
    this.categoryId, // Add this
    this.isCredit = false,
    this.contactName,
    this.contactPhone,
    this.mpesaReference,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'description': description,
      'date': date.millisecondsSinceEpoch,
      'category': category,
      'categoryId': categoryId, // Add this
      'isCredit': isCredit ? 1 : 0,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'mpesaReference': mpesaReference,
    };
  }

  factory BusinessTransaction.fromMap(Map<String, dynamic> map) {
    return BusinessTransaction(
      id: map['id'],
      amount: map['amount'],
      type: map['type'],
      description: map['description'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      category: map['category'],
      categoryId: map['categoryId'], // Add this
      isCredit: map['isCredit'] == 1,
      contactName: map['contactName'],
      contactPhone: map['contactPhone'],
      mpesaReference: map['mpesaReference'],
    );
  }
}
