import 'package:flutter/material.dart';
import '../models/credit.dart';
import '../services/database_service.dart';

class CreditProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Credit> _credits = [];

  List<Credit> get credits => _credits;
  List<Credit> get customerCredits =>
      _credits.where((credit) => credit.type == 'customer').toList();
  List<Credit> get supplierCredits =>
      _credits.where((credit) => credit.type == 'supplier').toList();
  List<Credit> get overdueCredits =>
      _credits.where((credit) => credit.isOverdue).toList();
  List<Credit> get pendingCredits =>
      _credits.where((credit) => credit.status == 'pending').toList();

  double get totalCustomerDebt =>
      customerCredits.fold(0.0, (sum, credit) => sum + credit.remainingAmount);
  double get totalSupplierDebt =>
      supplierCredits.fold(0.0, (sum, credit) => sum + credit.remainingAmount);

  CreditProvider() {
    loadCredits();
  }

  Future<void> loadCredits() async {
    _credits = await _databaseService.getCredits();
    notifyListeners();
  }

  Future<void> addCredit(Credit credit) async {
    await _databaseService.saveCredit(credit);
    await loadCredits();
  }

  Future<void> updateCredit(Credit updatedCredit) async {
    await _databaseService.saveCredit(updatedCredit);
    await loadCredits();
  }

  Future<void> deleteCredit(String creditId) async {
    await _databaseService.deleteCredit(creditId);
    _credits.removeWhere((credit) => credit.id == creditId);
    notifyListeners();
  }

  Future<void> addPayment(String creditId, PaymentRecord payment) async {
    final credit = _credits.firstWhere((c) => c.id == creditId);
    final updatedPayments = List<PaymentRecord>.from(credit.payments)
      ..add(payment);

    final updatedCredit = credit.copyWith(
      payments: updatedPayments,
    );

    await _databaseService.saveCredit(updatedCredit);
    await loadCredits();
  }

  bool isCreditOverdue(Credit credit) {
    if (credit.status != 'pending') return false;
    final now = DateTime.now();
    final daysOverdue = now.difference(credit.dueDate).inDays;
    return daysOverdue > 0;
  }

  double calculateTotalDebt(List<Credit> creditList) {
    return creditList.fold(0.0, (sum, credit) => sum + credit.remainingAmount);
  }
}
