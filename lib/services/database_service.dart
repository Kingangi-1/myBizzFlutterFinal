import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart';
import '../models/credit.dart';
import '../models/contact.dart';
import '../models/category.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  factory DatabaseService() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'mybizz.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createTables,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        category TEXT,
        is_credit INTEGER DEFAULT 0,
        contact_name TEXT,
        contact_phone TEXT,
        mpesa_reference TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE credits(
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        contact_id TEXT NOT NULL,
        contact_name TEXT NOT NULL,
        amount REAL NOT NULL,
        due_date TEXT NOT NULL,
        created_date TEXT NOT NULL,
        description TEXT,
        status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE payments(
        id TEXT PRIMARY KEY,
        credit_id TEXT NOT NULL,
        payment_date TEXT NOT NULL,
        amount REAL NOT NULL,
        method TEXT NOT NULL,
        reference TEXT,
        FOREIGN KEY (credit_id) REFERENCES credits (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE contacts(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        type TEXT NOT NULL,
        company TEXT,
        created_date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        color INTEGER,
        icon TEXT
      )
    ''');
  }

  Future<void> _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE credits(
          id TEXT PRIMARY KEY,
          type TEXT NOT NULL,
          contact_id TEXT NOT NULL,
          contact_name TEXT NOT NULL,
          amount REAL NOT NULL,
          due_date TEXT NOT NULL,
          created_date TEXT NOT NULL,
          description TEXT,
          status TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE payments(
          id TEXT PRIMARY KEY,
          credit_id TEXT NOT NULL,
          payment_date TEXT NOT NULL,
          amount REAL NOT NULL,
          method TEXT NOT NULL,
          reference TEXT,
          FOREIGN KEY (credit_id) REFERENCES credits (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE contacts(
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          phone TEXT,
          email TEXT,
          type TEXT NOT NULL,
          company TEXT,
          created_date TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE categories(
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          color INTEGER,
          icon TEXT
        )
      ''');
    }
  }

  // TRANSACTION OPERATIONS
  Future<int> insertTransaction(BusinessTransaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<BusinessTransaction>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('transactions', orderBy: 'date DESC');
    return List.generate(
        maps.length, (i) => BusinessTransaction.fromMap(maps[i]));
  }

  Future<List<BusinessTransaction>> getTransactionsByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    final List<Map<String, dynamic>> maps = await db.query('transactions',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
        orderBy: 'date DESC');

    return List.generate(
        maps.length, (i) => BusinessTransaction.fromMap(maps[i]));
  }

  Future<int> updateTransaction(BusinessTransaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalIncome() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions 
      WHERE type IN ('sale', 'mpesa_deposit')
    ''');
    return result.first['total'] as double? ?? 0.0;
  }

  Future<double> getTotalExpenses() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions 
      WHERE type IN ('expense', 'purchase', 'mpesa_withdrawal', 'drawing')
    ''');
    return result.first['total'] as double? ?? 0.0;
  }

  // CREDIT OPERATIONS
  Future<List<Credit>> getCredits() async {
    final db = await database;
    final List<Map<String, dynamic>> creditMaps =
        await db.query('credits', orderBy: 'due_date ASC');

    final List<Credit> credits = [];

    for (final creditMap in creditMaps) {
      final List<Map<String, dynamic>> paymentMaps = await db.query(
        'payments',
        where: 'credit_id = ?',
        whereArgs: [creditMap['id']],
        orderBy: 'payment_date DESC',
      );

      final List<PaymentRecord> payments = paymentMaps
          .map((paymentMap) => PaymentRecord.fromMap(paymentMap))
          .toList();

      final credit = Credit.fromMap(creditMap);
      final creditWithPayments = credit.copyWith(payments: payments);
      credits.add(creditWithPayments);
    }

    return credits;
  }

  Future<void> saveCredit(Credit credit) async {
    final db = await database;
    await db.insert(
      'credits',
      credit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    for (final payment in credit.payments) {
      await db.insert(
        'payments',
        payment.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> deleteCredit(String id) async {
    final db = await database;
    await db.delete('payments', where: 'credit_id = ?', whereArgs: [id]);
    await db.delete('credits', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addPayment(String creditId, PaymentRecord payment) async {
    final db = await database;
    await db.insert(
      'payments',
      payment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // CONTACT OPERATIONS
  Future<List<Contact>> getContacts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('contacts', orderBy: 'name ASC');
    return List.generate(maps.length, (i) => Contact.fromMap(maps[i]));
  }

  Future<List<Contact>> getContactsByType(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Contact.fromMap(maps[i]));
  }

  Future<void> saveContact(Contact contact) async {
    final db = await database;
    await db.insert(
      'contacts',
      contact.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteContact(String id) async {
    final db = await database;
    await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }

  // CATEGORY OPERATIONS
  Future<List<Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('categories', orderBy: 'name ASC');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<List<Category>> getCategoriesByType(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<void> saveCategory(Category category) async {
    final db = await database;
    await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteCategory(String id) async {
    final db = await database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
