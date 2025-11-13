import 'storage_service.dart';
import '../models/transaction.dart';

class MemoryStorageService implements StorageService {
  static final MemoryStorageService _instance =
      MemoryStorageService._internal();

  final List<BusinessTransaction> _transactions = [];
  final Map<String, String> _storage = {};
  Map<String, dynamic>? _businessProfile;

  MemoryStorageService._internal();

  factory MemoryStorageService() => _instance;

  // Business Profile Methods
  @override
  Future<Map<String, dynamic>?> getBusinessProfile() async {
    return _businessProfile;
  }

  @override
  Future<void> saveBusinessProfile(Map<String, dynamic> profile) async {
    _businessProfile = Map<String, dynamic>.from(profile);
  }

  // Generic Storage Methods
  @override
  Future<void> saveString(String key, String value) async {
    _storage[key] = value;
  }

  @override
  Future<String?> getString(String key) async {
    return _storage[key];
  }

  // Transaction Methods (implement with simple logic)
  @override
  Future<List<BusinessTransaction>> getTransactions() async {
    return List.from(_transactions);
  }

  @override
  Future<void> saveTransactions(List<BusinessTransaction> transactions) async {
    _transactions.clear();
    _transactions.addAll(transactions);
  }

  @override
  Future<void> addTransaction(BusinessTransaction transaction) async {
    _transactions.add(transaction);
  }

  @override
  Future<void> updateTransaction(BusinessTransaction transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
    }
  }

  @override
  Future<void> deleteTransaction(int id) async {
    _transactions.removeWhere((t) => t.id == id);
  }
}
