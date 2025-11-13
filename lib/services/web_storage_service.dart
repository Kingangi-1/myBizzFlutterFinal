import 'dart:convert';
import 'storage_service.dart';
import '../models/transaction.dart';

class WebStorageService implements StorageService {
  static const String _transactionsKey = 'mybizz_transactions';

  @override
  Future<List<BusinessTransaction>> getTransactions() async {
    // Simple web storage for development
    try {
      // This will be replaced with SQLite for mobile
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveTransactions(List<BusinessTransaction> transactions) async {
    // Simple implementation for web
  }

  @override
  Future<void> addTransaction(BusinessTransaction transaction) async {
    final transactions = await getTransactions();
    transactions.insert(0, transaction);
    await saveTransactions(transactions);
  }

  @override
  Future<void> updateTransaction(BusinessTransaction transaction) async {
    final transactions = await getTransactions();
    final index = transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      transactions[index] = transaction;
      await saveTransactions(transactions);
    }
  }

  @override
  Future<void> deleteTransaction(int id) async {
    final transactions = await getTransactions();
    transactions.removeWhere((t) => t.id == id);
    await saveTransactions(transactions);
  }
}
