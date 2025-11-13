import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false)
          .loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(value: 'all', child: Text('All Transactions')),
              PopupMenuItem(value: 'sales', child: Text('Sales Only')),
              PopupMenuItem(value: 'expenses', child: Text('Expenses Only')),
              PopupMenuItem(value: 'credit', child: Text('Credit Only')),
            ],
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          List<BusinessTransaction> filteredTransactions = _filterTransactions(
            transactionProvider.transactions,
            _selectedFilter,
          );

          return Column(
            children: [
              // Summary Bar
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.grey[50],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem('Total', filteredTransactions.length),
                    _buildSummaryItem(
                      'Income',
                      _calculateTotalIncome(filteredTransactions),
                      isAmount: true,
                    ),
                    _buildSummaryItem(
                      'Expenses',
                      _calculateTotalExpenses(filteredTransactions),
                      isAmount: true,
                    ),
                  ],
                ),
              ),
              // Transactions List
              Expanded(
                child: filteredTransactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No transactions found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              _getEmptyStateMessage(_selectedFilter),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = filteredTransactions[index];
                          return _TransactionListItem(transaction: transaction);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTransactionScreen()),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: AppConstants.primaryColor,
      ),
    );
  }

  Widget _buildSummaryItem(String label, dynamic value,
      {bool isAmount = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Text(
          isAmount ? 'KES ${value.toStringAsFixed(2)}' : value.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _getSummaryColor(label, value, isAmount),
          ),
        ),
      ],
    );
  }

  Color _getSummaryColor(String label, dynamic value, bool isAmount) {
    if (!isAmount) return Colors.black;

    switch (label) {
      case 'Income':
        return Colors.green;
      case 'Expenses':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  List<BusinessTransaction> _filterTransactions(
      List<BusinessTransaction> transactions, String filter) {
    switch (filter) {
      case 'sales':
        return transactions.where((t) => Helpers.isIncomeType(t.type)).toList();
      case 'expenses':
        return transactions
            .where((t) => Helpers.isExpenseType(t.type))
            .toList();
      case 'credit':
        return transactions.where((t) => t.isCredit).toList();
      default:
        return transactions;
    }
  }

  double _calculateTotalIncome(List<BusinessTransaction> transactions) {
    return transactions
        .where((t) => Helpers.isIncomeType(t.type))
        .fold(0, (sum, t) => sum + t.amount);
  }

  double _calculateTotalExpenses(List<BusinessTransaction> transactions) {
    return transactions
        .where((t) => Helpers.isExpenseType(t.type))
        .fold(0, (sum, t) => sum + t.amount);
  }

  String _getEmptyStateMessage(String filter) {
    switch (filter) {
      case 'sales':
        return 'No sales transactions yet';
      case 'expenses':
        return 'No expense transactions yet';
      case 'credit':
        return 'No credit transactions yet';
      default:
        return 'Add your first transaction to get started';
    }
  }
}

class _TransactionListItem extends StatelessWidget {
  final BusinessTransaction transaction;

  const _TransactionListItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = Helpers.isIncomeType(transaction.type);
    final icon = Helpers.getTransactionIcon(transaction.type);
    final color = isIncome ? Colors.green : Colors.red;
    final sign = isIncome ? '+' : '-';
    final typeDisplay = Helpers.getTransactionTypeDisplay(transaction.type);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeDisplay,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  transaction.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  Helpers.formatDateForDisplay(transaction.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                if (transaction.isCredit)
                  Container(
                    margin: EdgeInsets.only(top: 4),
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'CREDIT',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign KSh ${transaction.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: 4),
              if (transaction.contactName != null)
                Text(
                  'With: ${transaction.contactName!}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
