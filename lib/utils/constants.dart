import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'myBizz';
  static const String currency = 'KES';

  static const List<String> transactionTypes = [
    'sale',
    'purchase',
    'expense',
    'mpesa_deposit',
    'mpesa_withdrawal',
    'drawing',
  ];

  static const List<String> expenseCategories = [
    'Food & Drinks',
    'Transport',
    'Airtime & Data',
    'Rent',
    'Utilities',
    'Salaries',
    'Marketing',
    'Other',
  ];

  static const Color primaryColor = Color(0xFF2E8B57);
  static const Color secondaryColor = Color(0xFF1E40AF);
  static const Color accentColor = Color(0xFFEA580C);
}
