import '../models/transaction.dart';

abstract class StorageService {
  // Transaction methods
  Future<List<BusinessTransaction>> getTransactions();
  Future<void> saveTransactions(List<BusinessTransaction> transactions);
  Future<void> addTransaction(BusinessTransaction transaction);
  Future<void> updateTransaction(BusinessTransaction transaction);
  Future<void> deleteTransaction(int id);

  // Business profile methods
  Future<Map<String, dynamic>?> getBusinessProfile();
  Future<void> saveBusinessProfile(Map<String, dynamic> profile);

  // Generic key-value storage
  Future<void> saveString(String key, String value);
  Future<String?> getString(String key);
}
