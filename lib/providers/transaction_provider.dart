import 'package:flutter/foundation.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  List<BusinessTransaction> _transactions = [];
  List<BusinessTransaction> get transactions => _transactions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Counter for generating unique IDs (for web storage)
  int _nextId = 1;

  TransactionProvider() {
    loadTransactions();
  }

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

  // ===========================================================================
  // ANALYTICS METHODS FOR REPORTS
  // ===========================================================================

  // Get transactions by month
  List<BusinessTransaction> getTransactionsByMonth(DateTime month) {
    return _transactions.where((transaction) {
      return transaction.date.year == month.year &&
          transaction.date.month == month.month;
    }).toList();
  }

  // Get income transactions by month
  List<BusinessTransaction> getIncomeTransactionsByMonth(DateTime month) {
    return getTransactionsByMonth(month).where((transaction) {
      return transaction.type == 'sale' || transaction.type == 'mpesa_deposit';
    }).toList();
  }

  // Get expense transactions by month
  List<BusinessTransaction> getExpenseTransactionsByMonth(DateTime month) {
    return getTransactionsByMonth(month).where((transaction) {
      return transaction.type == 'expense' ||
          transaction.type == 'purchase' ||
          transaction.type == 'mpesa_withdrawal' ||
          transaction.type == 'drawing';
    }).toList();
  }

  // Get income by category for a specific month
  Map<String, double> getIncomeByCategory(DateTime month) {
    final incomeTransactions = getIncomeTransactionsByMonth(month);
    final categories = <String, double>{};

    for (final transaction in incomeTransactions) {
      final category = transaction.category ?? 'Uncategorized';
      categories[category] = (categories[category] ?? 0) + transaction.amount;
    }

    return categories;
  }

  // Get expenses by category for a specific month
  Map<String, double> getExpensesByCategory(DateTime month) {
    final expenseTransactions = getExpenseTransactionsByMonth(month);
    final categories = <String, double>{};

    for (final transaction in expenseTransactions) {
      final category =
          transaction.category ?? _getDefaultExpenseCategory(transaction.type);
      categories[category] = (categories[category] ?? 0) + transaction.amount;
    }

    return categories;
  }

  String _getDefaultExpenseCategory(String type) {
    switch (type) {
      case 'purchase':
        return 'Purchases';
      case 'expense':
        return 'General Expenses';
      case 'mpesa_withdrawal':
        return 'M-Pesa Withdrawals';
      case 'drawing':
        return 'Owner Drawings';
      default:
        return 'Other Expenses';
    }
  }

  // ===========================================================================
  // FINANCIAL SUMMARY METHODS
  // ===========================================================================

  double getTodaySales() {
    final today = DateTime.now();
    return _transactions
        .where((t) =>
            t.date.day == today.day &&
            t.date.month == today.month &&
            t.date.year == today.year &&
            (t.type == 'sale' || t.type == 'mpesa_deposit'))
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
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
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double getNetCash() {
    return getTodaySales() - getTodayExpenses();
  }

  double getTotalIncome() {
    return _transactions
        .where((t) => t.type == 'sale' || t.type == 'mpesa_deposit')
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double getTotalExpenses() {
    return _transactions
        .where((t) =>
            t.type == 'expense' ||
            t.type == 'purchase' ||
            t.type == 'mpesa_withdrawal' ||
            t.type == 'drawing')
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  // Get monthly income
  double getMonthlyIncome(DateTime month) {
    return getIncomeTransactionsByMonth(month)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  // Get monthly expenses
  double getMonthlyExpenses(DateTime month) {
    return getExpenseTransactionsByMonth(month)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  // Get monthly net profit
  double getMonthlyNetProfit(DateTime month) {
    return getMonthlyIncome(month) - getMonthlyExpenses(month);
  }

  // ===========================================================================
  // TREND ANALYSIS METHODS
  // ===========================================================================

  // Get monthly trends for the last 6 months
  Map<String, Map<String, double>> getMonthlyTrends({int months = 6}) {
    final now = DateTime.now();
    final trends = <String, Map<String, double>>{};

    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i);
      final monthKey = _formatMonthKey(month);

      trends[monthKey] = {
        'income': getMonthlyIncome(month),
        'expenses': getMonthlyExpenses(month),
        'profit': getMonthlyNetProfit(month),
      };
    }

    return trends;
  }

  String _formatMonthKey(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
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

    // Optional: Add some sample data for testing reports
    /*
    return [
      BusinessTransaction(
        id: 1,
        amount: 15000,
        type: 'sale',
        description: 'Product sales - Electronics',
        date: DateTime.now().subtract(Duration(days: 2)),
        category: 'Electronics',
      ),
      BusinessTransaction(
        id: 2,
        amount: 5000,
        type: 'sale',
        description: 'Clothing sales',
        date: DateTime.now().subtract(Duration(days: 5)),
        category: 'Clothing',
      ),
      BusinessTransaction(
        id: 3,
        amount: 2500,
        type: 'expense',
        description: 'Office supplies',
        date: DateTime.now().subtract(Duration(days: 1)),
        category: 'Supplies',
      ),
      BusinessTransaction(
        id: 4,
        amount: 3000,
        type: 'purchase',
        description: 'Inventory restock',
        date: DateTime.now().subtract(Duration(days: 3)),
        category: 'Inventory',
      ),
      BusinessTransaction(
        id: 5,
        amount: 1200,
        type: 'mpesa_withdrawal',
        description: 'Cash withdrawal',
        date: DateTime.now().subtract(Duration(days: 7)),
        category: 'Withdrawals',
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
