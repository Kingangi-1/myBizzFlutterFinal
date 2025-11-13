import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';
import 'add_transaction_screen.dart';
import 'transactions_screen.dart'; // ADD THIS IMPORT

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when screen starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false)
          .loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          final totalIncome =
              _calculateTotalIncome(transactionProvider.transactions);
          final totalExpenses =
              _calculateTotalExpenses(transactionProvider.transactions);
          final netCash = totalIncome - totalExpenses;
          final recentTransactions = transactionProvider.transactions.length > 4
              ? transactionProvider.transactions.sublist(0, 4)
              : transactionProvider.transactions;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),

                // Header
                Text(
                  'Dash',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Hello, Business Owner',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 24),

                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Total Income',
                        amount: totalIncome,
                        color: Colors.green,
                        icon: Icons.arrow_upward,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Total Expenses',
                        amount: totalExpenses,
                        color: Colors.red,
                        icon: Icons.arrow_downward,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                _SummaryCard(
                  title: 'Net Cash',
                  amount: netCash,
                  color: netCash >= 0 ? Colors.blue : Colors.orange,
                  icon: Icons.account_balance_wallet,
                ),
                SizedBox(height: 24),

                // Quick Actions Section
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),

                // Quick Action Buttons - Row 1
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.add_shopping_cart,
                        label: 'Add Sale',
                        color: Colors.green,
                        onTap: () => _quickAddTransaction(context, 'sale'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.inventory_2,
                        label: 'Add Purchase',
                        color: Colors.blue,
                        onTap: () => _quickAddTransaction(context, 'purchase'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Quick Action Buttons - Row 2
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.money_off,
                        label: 'Add Expense',
                        color: Colors.orange,
                        onTap: () => _quickAddTransaction(context, 'expense'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.phone_android,
                        label: 'M-PESA',
                        color: Colors.teal,
                        onTap: () =>
                            _quickAddTransaction(context, 'mpesa_deposit'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Quick Action Buttons - Row 3
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.credit_card,
                        label: 'Sales on Credit',
                        color: Colors.purple,
                        onTap: () =>
                            _quickAddTransaction(context, 'sale_credit'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.person,
                        label: 'Owner Drawing',
                        color: Colors.brown,
                        onTap: () => _quickAddTransaction(context, 'drawing'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Recent Transactions Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TransactionsScreen()),
                        );
                      },
                      child: Text(
                        'View All',
                        style: TextStyle(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // Recent Transactions List
                Column(
                  children: recentTransactions
                      .map((transaction) =>
                          _TransactionItem(transaction: transaction))
                      .toList(),
                ),

                // Empty State
                if (recentTransactions.isEmpty)
                  Container(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No transactions yet',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add your first transaction to get started',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[400],
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _quickAddTransaction(context, 'sale');
                          },
                          child: Text('Add First Transaction'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
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

  double _calculateTotalIncome(List<BusinessTransaction> transactions) {
    return transactions
        .where((t) => Helpers.isIncomeType(t.type))
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double _calculateTotalExpenses(List<BusinessTransaction> transactions) {
    return transactions
        .where((t) => Helpers.isExpenseType(t.type))
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  void _quickAddTransaction(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (context) => _QuickAddDialog(type: type),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Text(
                'KSh ${amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final BusinessTransaction transaction;

  const _TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = Helpers.isIncomeType(transaction.type);
    final icon = Helpers.getTransactionIcon(transaction.type);
    final color = isIncome ? Colors.green : Colors.red;
    final sign = isIncome ? '+' : '-';

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
                  Helpers.getTransactionTypeDisplay(transaction.type),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  transaction.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
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
                        fontSize: 8,
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
              Text(
                Helpers.formatDateForDisplay(transaction.date),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAddDialog extends StatefulWidget {
  final String type;

  const _QuickAddDialog({required this.type});

  @override
  __QuickAddDialogState createState() => __QuickAddDialogState();
}

class __QuickAddDialogState extends State<_QuickAddDialog> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String get _typeDisplay {
    switch (widget.type) {
      case 'sale':
        return 'Sale';
      case 'purchase':
        return 'Purchase';
      case 'expense':
        return 'Expense';
      case 'mpesa_deposit':
        return 'M-PESA Deposit';
      case 'sale_credit':
        return 'Sale on Credit';
      case 'drawing':
        return 'Owner Drawing';
      default:
        return 'Transaction';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Quick Add $_typeDisplay'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount (KES)',
              prefixText: 'KES ',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter amount';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
              hintText: 'Enter description...',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter description';
              }
              return null;
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addTransaction,
          child: Text('Add'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
          ),
        ),
      ],
    );
  }

  void _addTransaction() {
    if (_amountController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty) {
      final isCredit = widget.type == 'sale_credit';
      final actualType = widget.type.replaceAll('_credit', '');

      final transaction = BusinessTransaction(
        amount: double.parse(_amountController.text),
        type: actualType,
        description: _descriptionController.text,
        date: DateTime.now(),
        isCredit: isCredit,
      );

      Provider.of<TransactionProvider>(context, listen: false)
          .addTransaction(transaction)
          .then((_) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_typeDisplay added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
