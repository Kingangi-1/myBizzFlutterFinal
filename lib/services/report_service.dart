import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/credit.dart';

class ReportService {
  // Generate aging analysis for credits
  Map<String, double> getAgingAnalysis(List<Credit> credits) {
    final now = DateTime.now();
    Map<String, double> aging = {
      'current': 0.0,
      '1-30': 0.0,
      '31-60': 0.0,
      '61+': 0.0,
    };

    for (final credit in credits) {
      if (credit.status != 'pending') continue;

      final daysOverdue = now.difference(credit.dueDate).inDays;
      final amount = credit.remainingAmount;

      if (daysOverdue <= 0) {
        aging['current'] = aging['current']! + amount;
      } else if (daysOverdue <= 30) {
        aging['1-30'] = aging['1-30']! + amount;
      } else if (daysOverdue <= 60) {
        aging['31-60'] = aging['31-60']! + amount;
      } else {
        aging['61+'] = aging['61+']! + amount;
      }
    }

    return aging;
  }

  // Generate profit and loss statement
  Map<String, dynamic> generateProfitLossStatement(
      List<BusinessTransaction> transactions, DateTime month) {
    final incomeItems = <Map<String, dynamic>>[];
    final expenseItems = <Map<String, dynamic>>[];

    double totalIncome = 0;
    double totalExpenses = 0;

    // Filter transactions for the selected month
    final monthTransactions = transactions.where((transaction) {
      return transaction.date.year == month.year &&
          transaction.date.month == month.month;
    }).toList();

    // Categorize transactions
    final incomeCategories = <String, double>{};
    final expenseCategories = <String, double>{};

    for (final transaction in monthTransactions) {
      if (transaction.type == 'sale' || transaction.type == 'mpesa_deposit') {
        // Income transaction
        final category = transaction.category ?? 'Sales';
        incomeCategories[category] =
            (incomeCategories[category] ?? 0) + transaction.amount;
        totalIncome += transaction.amount;
      } else {
        // Expense transaction
        final category =
            transaction.category ?? _getExpenseCategory(transaction.type);
        expenseCategories[category] =
            (expenseCategories[category] ?? 0) + transaction.amount;
        totalExpenses += transaction.amount;
      }
    }

    // Convert to list format for display
    incomeCategories.forEach((category, amount) {
      incomeItems.add({
        'category': category,
        'amount': amount,
      });
    });

    expenseCategories.forEach((category, amount) {
      expenseItems.add({
        'category': category,
        'amount': amount,
      });
    });

    return {
      'income': incomeItems,
      'expenses': expenseItems,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'netProfit': totalIncome - totalExpenses,
    };
  }

  String _getExpenseCategory(String type) {
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

  // Get monthly summary for charts
  Map<String, Map<String, double>> getMonthlySummary(
      List<BusinessTransaction> transactions, int monthsBack) {
    final now = DateTime.now();
    final summary = <String, Map<String, double>>{};

    for (int i = monthsBack - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i);
      final monthKey = DateFormat('MMM yyyy').format(month);

      summary[monthKey] = {
        'income': 0.0,
        'expenses': 0.0,
      };
    }

    for (final transaction in transactions) {
      final monthKey = DateFormat('MMM yyyy').format(transaction.date);

      if (summary.containsKey(monthKey)) {
        if (transaction.type == 'sale' || transaction.type == 'mpesa_deposit') {
          summary[monthKey]!['income'] =
              summary[monthKey]!['income']! + transaction.amount;
        } else {
          summary[monthKey]!['expenses'] =
              summary[monthKey]!['expenses']! + transaction.amount;
        }
      }
    }

    return summary;
  }

  // Export data (placeholder - will be implemented with actual export functionality)
  Future<void> exportToPDF(Map<String, dynamic> data) async {
    // PDF export implementation
    await Future.delayed(Duration(seconds: 1));
  }

  Future<void> exportToExcel(Map<String, dynamic> data) async {
    // Excel export implementation
    await Future.delayed(Duration(seconds: 1));
  }

  Future<void> exportToCSV(Map<String, dynamic> data) async {
    // CSV export implementation
    await Future.delayed(Duration(seconds: 1));
  }
}
