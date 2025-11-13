import 'package:flutter/material.dart';
import '../models/credit.dart';
import '../services/database_service.dart';

class CreditProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Credit> _credits = [];
  bool _isLoading = false;

  List<Credit> get credits => _credits;
  bool get isLoading => _isLoading;

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
  double get totalOverdueAmount =>
      overdueCredits.fold(0.0, (sum, credit) => sum + credit.remainingAmount);

  CreditProvider() {
    loadCredits();
  }

  Future<void> loadCredits() async {
    _isLoading = true;
    notifyListeners();

    try {
      _credits = await _databaseService.getCredits();
    } catch (e) {
      print('Error loading credits: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCredit(Credit credit) async {
    try {
      await _databaseService.saveCredit(credit);
      await loadCredits(); // Reload to get the updated list
    } catch (e) {
      print('Error adding credit: $e');
      rethrow;
    }
  }

  Future<void> updateCredit(Credit updatedCredit) async {
    try {
      await _databaseService.saveCredit(updatedCredit);
      await loadCredits();
    } catch (e) {
      print('Error updating credit: $e');
      rethrow;
    }
  }

  Future<void> deleteCredit(String id) async {
    try {
      await _databaseService.deleteCredit(id);
      _credits.removeWhere((credit) => credit.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting credit: $e');
      rethrow;
    }
  }

  Future<void> addPayment(String creditId, PaymentRecord payment) async {
    try {
      final credit = _credits.firstWhere((c) => c.id == creditId);
      final updatedPayments = List<PaymentRecord>.from(credit.payments)
        ..add(payment);

      // Update credit status if fully paid
      final newRemaining = credit.amount -
          (payment.amount + _calculateTotalPaid(credit.payments));
      final newStatus = newRemaining <= 0 ? 'paid' : credit.status;

      final updatedCredit = credit.copyWith(
        payments: updatedPayments,
        status: newStatus,
      );

      await _databaseService.saveCredit(updatedCredit);
      await loadCredits();
    } catch (e) {
      print('Error adding payment: $e');
      rethrow;
    }
  }

  double _calculateTotalPaid(List<PaymentRecord> payments) {
    return payments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  List<Credit> getCreditsByContact(String contactId) {
    return _credits.where((credit) => credit.contactId == contactId).toList();
  }

  // Analytics methods
  Map<String, double> getCreditSummaryByMonth() {
    final now = DateTime.now();
    final Map<String, double> monthlySummary = {};

    for (final credit in _credits) {
      final monthKey = '${credit.dueDate.year}-${credit.dueDate.month}';
      monthlySummary[monthKey] =
          (monthlySummary[monthKey] ?? 0) + credit.remainingAmount;
    }

    return monthlySummary;
  }

  List<Credit> getUpcomingCredits({int days = 7}) {
    final cutoffDate = DateTime.now().add(Duration(days: days));
    return _credits
        .where((credit) =>
            credit.status == 'pending' &&
            credit.dueDate.isBefore(cutoffDate) &&
            !credit.dueDate.isBefore(DateTime.now()))
        .toList();
  }
}
