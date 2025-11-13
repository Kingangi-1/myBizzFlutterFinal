import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {
  static String formatDateForDisplay(DateTime date) {
    return DateFormat('EEE, MMM d, y').format(date);
  }

  static String formatTimeForDisplay(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String getTransactionTypeDisplay(String type) {
    switch (type) {
      case 'sale':
        return 'Sale';
      case 'purchase':
        return 'Purchase';
      case 'expense':
        return 'Expense';
      case 'mpesa_deposit':
        return 'M-PESA Deposit';
      case 'mpesa_withdrawal':
        return 'M-PESA Withdrawal';
      case 'drawing':
        return 'Owner Drawing';
      default:
        return type;
    }
  }

  static bool isIncomeType(String type) {
    return type == 'sale' || type == 'mpesa_deposit';
  }

  static bool isExpenseType(String type) {
    return type == 'expense' ||
        type == 'purchase' ||
        type == 'mpesa_withdrawal' ||
        type == 'drawing';
  }

  static IconData getTransactionIcon(String type) {
    switch (type) {
      case 'sale':
        return Icons.shopping_cart;
      case 'purchase':
        return Icons.inventory_2;
      case 'expense':
        return Icons.money_off;
      case 'mpesa_deposit':
        return Icons.phone_android;
      case 'mpesa_withdrawal':
        return Icons.phone_android;
      case 'drawing':
        return Icons.person;
      default:
        return Icons.receipt;
    }
  }

  static Color getTransactionColor(String type) {
    if (isIncomeType(type)) return Colors.green;
    if (isExpenseType(type)) return Colors.orange;
    return Colors.grey;
  }
}
