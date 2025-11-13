class Credit {
  final String id;
  final String type;
  final String contactId;
  final String contactName;
  final double amount;
  final DateTime dueDate;
  final DateTime createdDate;
  final String? description;
  final String status;
  final List<PaymentRecord> payments;

  Credit({
    required this.id,
    required this.type,
    required this.contactId,
    required this.contactName,
    required this.amount,
    required this.dueDate,
    required this.createdDate,
    this.description,
    required this.status,
    this.payments = const [],
  });

  double get remainingAmount {
    final paid = payments.fold(0.0, (sum, payment) => sum + payment.amount);
    return amount - paid;
  }

  bool get isOverdue {
    return status == 'pending' && dueDate.isBefore(DateTime.now());
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'contact_id': contactId,
      'contact_name': contactName,
      'amount': amount,
      'due_date': dueDate.toIso8601String(),
      'created_date': createdDate.toIso8601String(),
      'description': description,
      'status': status,
    };
  }

  factory Credit.fromMap(Map<String, dynamic> map) {
    return Credit(
      id: map['id'],
      type: map['type'],
      contactId: map['contact_id'],
      contactName: map['contact_name'],
      amount: map['amount'],
      dueDate: DateTime.parse(map['due_date']),
      createdDate: DateTime.parse(map['created_date']),
      description: map['description'],
      status: map['status'],
    );
  }

  Credit copyWith({
    String? id,
    String? type,
    String? contactId,
    String? contactName,
    double? amount,
    DateTime? dueDate,
    DateTime? createdDate,
    String? description,
    String? status,
    List<PaymentRecord>? payments,
  }) {
    return Credit(
      id: id ?? this.id,
      type: type ?? this.type,
      contactId: contactId ?? this.contactId,
      contactName: contactName ?? this.contactName,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      createdDate: createdDate ?? this.createdDate,
      description: description ?? this.description,
      status: status ?? this.status,
      payments: payments ?? this.payments,
    );
  }
}

class PaymentRecord {
  final String id;
  final String creditId;
  final DateTime paymentDate;
  final double amount;
  final String method;
  final String? reference;

  PaymentRecord({
    required this.id,
    required this.creditId,
    required this.paymentDate,
    required this.amount,
    required this.method,
    this.reference,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'credit_id': creditId,
      'payment_date': paymentDate.toIso8601String(),
      'amount': amount,
      'method': method,
      'reference': reference,
    };
  }

  factory PaymentRecord.fromMap(Map<String, dynamic> map) {
    return PaymentRecord(
      id: map['id'],
      creditId: map['credit_id'],
      paymentDate: DateTime.parse(map['payment_date']),
      amount: map['amount'],
      method: map['method'],
      reference: map['reference'],
    );
  }
}
