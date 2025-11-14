import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/category.dart';

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
        categoryId: transaction.categoryId, // Add this
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

  // ===========================================================================
  // CATEGORY-RELATED METHODS
  // ===========================================================================

  // Get transactions by category ID
  List<BusinessTransaction> getTransactionsByCategory(String categoryId) {
    return _transactions.where((t) => t.categoryId == categoryId).toList();
  }

  // Get category total for a specific period
  double getCategoryTotal(String categoryId, String type, {DateTime? month}) {
    var filtered = _transactions
        .where((t) => t.categoryId == categoryId && t.type == type);

    if (month != null) {
      filtered = filtered.where(
          (t) => t.date.year == month.year && t.date.month == month.month);
    }

    return filtered.fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  // Get transactions for a specific category and period
  List<BusinessTransaction> getCategoryTransactions(
    String categoryId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    var filtered = _transactions.where((t) => t.categoryId == categoryId);

    if (startDate != null) {
      filtered = filtered
          .where((t) => t.date.isAfter(startDate.subtract(Duration(days: 1))));
    }

    if (endDate != null) {
      filtered = filtered
          .where((t) => t.date.isBefore(endDate.add(Duration(days: 1))));
    }

    return filtered.toList();
  }

  // Get top categories by amount
  Map<String, double> getTopCategories(String type,
      {int limit = 5, DateTime? month}) {
    final categoryTotals = <String, double>{};

    var filtered = _transactions.where((t) => t.type == type);

    if (month != null) {
      filtered = filtered.where(
          (t) => t.date.year == month.year && t.date.month == month.month);
    }

    for (final transaction in filtered) {
      final categoryId = transaction.categoryId ?? 'uncategorized';
      final categoryName = transaction.category ?? 'Uncategorized';
      final key = '$categoryId|$categoryName';
      categoryTotals[key] = (categoryTotals[key] ?? 0) + transaction.amount;
    }

    // Sort by amount descending and take top N
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final result = <String, double>{};
    for (int i = 0; i < limit && i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      final categoryName = entry.key.split('|')[1];
      result[categoryName] = entry.value;
    }

    return result;
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

  // Enhanced version with category IDs
  Map<String, Map<String, dynamic>> getExpensesByCategoryWithDetails(
      DateTime month) {
    final expenseTransactions = getExpenseTransactionsByMonth(month);
    final categories = <String, Map<String, dynamic>>{};

    for (final transaction in expenseTransactions) {
      final categoryName =
          transaction.category ?? _getDefaultExpenseCategory(transaction.type);
      final categoryId =
          transaction.categoryId ?? 'default_${transaction.type}';

      if (!categories.containsKey(categoryId)) {
        categories[categoryId] = {
          'name': categoryName,
          'amount': 0.0,
          'count': 0,
          'transactions': <BusinessTransaction>[],
        };
      }

      categories[categoryId]!['amount'] =
          (categories[categoryId]!['amount'] as double) + transaction.amount;
      categories[categoryId]!['count'] =
          (categories[categoryId]!['count'] as int) + 1;
      (categories[categoryId]!['transactions'] as List<BusinessTransaction>)
          .add(transaction);
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
        categoryId: '1',
      ),
      BusinessTransaction(
        id: 2,
        amount: 5000,
        type: 'sale',
        description: 'Clothing sales',
        date: DateTime.now().subtract(Duration(days: 5)),
        category: 'Clothing',
        categoryId: '2',
      ),
      BusinessTransaction(
        id: 3,
        amount: 2500,
        type: 'expense',
        description: 'Office supplies',
        date: DateTime.now().subtract(Duration(days: 1)),
        category: 'Supplies',
        categoryId: '4',
      ),
      BusinessTransaction(
        id: 4,
        amount: 3000,
        type: 'purchase',
        description: 'Inventory restock',
        date: DateTime.now().subtract(Duration(days: 3)),
        category: 'Inventory',
        categoryId: '5',
      ),
      BusinessTransaction(
        id: 5,
        amount: 1200,
        type: 'mpesa_withdrawal',
        description: 'Cash withdrawal',
        date: DateTime.now().subtract(Duration(days: 7)),
        category: 'Withdrawals',
        categoryId: '6',
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
}
