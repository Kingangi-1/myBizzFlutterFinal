import 'package:flutter/foundation.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  List<BusinessTransaction> _transactions = [];
  List<BusinessTransaction> get transactions => _transactions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Counter for generating unique IDs (for web storage)
  int _nextId = 1;

  // Load all transactions (web-compatible version)
  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      // For web development - simple in-memory storage
      // This will be replaced with DatabaseHelper for mobile
      _transactions = _getStoredTransactions();

      // Set next ID based on existing transactions
      if (_transactions.isNotEmpty) {
        _nextId = (_transactions
                .map((t) => t.id ?? 0)
                .reduce((a, b) => a > b ? a : b)) +
            1;
      }
    } catch (e) {
      print('Error loading transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new transaction (web-compatible version)
  Future<void> addTransaction(BusinessTransaction transaction) async {
    try {
      final transactionWithId = BusinessTransaction(
        id: _nextId++,
        amount: transaction.amount,
        type: transaction.type,
        description: transaction.description,
        date: transaction.date,
        category: transaction.category,
        isCredit: transaction.isCredit,
        contactName: transaction.contactName,
        contactPhone: transaction.contactPhone,
        mpesaReference: transaction.mpesaReference,
      );

      // For web development - add to in-memory list
      _transactions.insert(0, transactionWithId);
      _saveTransactions(_transactions);

      notifyListeners();
    } catch (e) {
      print('Error adding transaction: $e');
      rethrow;
    }
  }

  // Update existing transaction (web-compatible version)
  Future<void> updateTransaction(BusinessTransaction transaction) async {
    try {
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        _saveTransactions(_transactions);
        notifyListeners();
      }
    } catch (e) {
      print('Error updating transaction: $e');
      rethrow;
    }
  }

  // Delete transaction (web-compatible version)
  Future<void> deleteTransaction(int id) async {
    try {
      _transactions.removeWhere((t) => t.id == id);
      _saveTransactions(_transactions);
      notifyListeners();
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    }
  }

  // Get today's transactions
  Future<List<BusinessTransaction>> getTodayTransactions() async {
    final today = DateTime.now();
    return _transactions
        .where((t) =>
            t.date.day == today.day &&
            t.date.month == today.month &&
            t.date.year == today.year)
        .toList();
  }

  // Analytics methods
  double getTodaySales() {
    final today = DateTime.now();
    return _transactions
        .where((t) =>
            t.date.day == today.day &&
            t.date.month == today.month &&
            t.date.year == today.year &&
            (t.type == 'sale' || t.type == 'mpesa_deposit'))
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  double getTodayExpenses() {
    final today = DateTime.now();
    return _transactions
        .where((t) =>
            t.date.day == today.day &&
            t.date.month == today.month &&
            t.date.year == today.year &&
            (t.type == 'expense' ||
                t.type == 'purchase' ||
                t.type == 'mpesa_withdrawal' ||
                t.type == 'drawing'))
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  double getNetCash() {
    return getTodaySales() - getTodayExpenses();
  }

  double getTotalIncome() {
    return _transactions
        .where((t) => t.type == 'sale' || t.type == 'mpesa_deposit')
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  double getTotalExpenses() {
    return _transactions
        .where((t) =>
            t.type == 'expense' ||
            t.type == 'purchase' ||
            t.type == 'mpesa_withdrawal' ||
            t.type == 'drawing')
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  // ===========================================================================
  // WEB-COMPATIBLE STORAGE METHODS
  // These will be replaced with DatabaseHelper for mobile production
  // ===========================================================================

  // Simple in-memory storage for web development
  List<BusinessTransaction> _getStoredTransactions() {
    // For web development - return empty list or some sample data
    // In a real app, you might use shared_preferences or local storage
    return [];

    // Optional: Add some sample data for testing
    /*
    return [
      BusinessTransaction(
        id: 1,
        amount: 3500,
        type: 'sale',
        description: 'Product sales',
        date: DateTime.now(),
      ),
      BusinessTransaction(
        id: 2,
        amount: 500,
        type: 'expense',
        description: 'Transport',
        date: DateTime.now(),
      ),
    ];
    */
  }

  void _saveTransactions(List<BusinessTransaction> transactions) {
    // For web development - do nothing or save to local storage
    // In a real app, you might use shared_preferences
    print('Transactions saved (${transactions.length} items)');

    // Optional: Save to browser's local storage
    // _saveToLocalStorage(transactions);
  }

  // Optional: Local storage implementation for web
  /*
  void _saveToLocalStorage(List<BusinessTransaction> transactions) {
    try {
      final transactionsJson = transactions.map((t) => t.toMap()).toList();
      // Use shared_preferences or window.localStorage here
    } catch (e) {
      print('Error saving to local storage: $e');
    }
  }
  */
}
