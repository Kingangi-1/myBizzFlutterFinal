//# Replace the entire transaction.dart file
//@"
class BusinessTransaction {
  int? id;
  final double amount;
  final String type;
  final String description;
  final DateTime date;
  final String? category;
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
      'date': date.toIso8601String(),
      'category': category,
      'is_credit': isCredit ? 1 : 0,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'mpesa_reference': mpesaReference,
    };
  }

  factory BusinessTransaction.fromMap(Map<String, dynamic> map) {
    return BusinessTransaction(
      id: map['id'],
      amount: map['amount'],
      type: map['type'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      category: map['category'],
      isCredit: map['is_credit'] == 1,
      contactName: map['contact_name'],
      contactPhone: map['contact_phone'],
      mpesaReference: map['mpesa_reference'],
    );
  }
}
//"@ | Out-File -FilePath "lib\models\transaction.dart" -Encoding utf8
