import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/credit_provider.dart';
import '../models/credit.dart';
import 'add_credit_screen.dart';
import 'credit_detail_screen.dart';

class CreditsScreen extends StatefulWidget {
  @override
  _CreditsScreenState createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Credit Management'),
        backgroundColor: Colors.blue[700],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All Credits'),
            Tab(text: 'Customers'),
            Tab(text: 'Suppliers'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddCreditScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<CreditProvider>(
        builder: (context, creditProvider, child) {
          if (creditProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildCreditsList(creditProvider.credits, creditProvider),
              _buildCreditsList(creditProvider.customerCredits, creditProvider),
              _buildCreditsList(creditProvider.supplierCredits, creditProvider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCreditScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[700],
      ),
    );
  }

  Widget _buildCreditsList(
      List<Credit> credits, CreditProvider creditProvider) {
    if (credits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.credit_card_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No credits found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: credits.length,
      itemBuilder: (context, index) {
        final credit = credits[index];
        return CreditCard(
          credit: credit,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreditDetailScreen(credit: credit),
              ),
            );
          },
        );
      },
    );
  }
}

class CreditCard extends StatelessWidget {
  final Credit credit;
  final VoidCallback onTap;

  const CreditCard({required this.credit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              credit.type == 'customer' ? Colors.green : Colors.orange,
          child: Icon(
            credit.type == 'customer'
                ? Icons.arrow_downward
                : Icons.arrow_upward,
            color: Colors.white,
          ),
        ),
        title: Text(
          credit.contactName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('KES ${credit.amount.toStringAsFixed(2)}'),
            Text('Due: ${_formatDate(credit.dueDate)}'),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(credit),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    credit.statusDisplay,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                SizedBox(width: 8),
                if (credit.remainingAmount > 0)
                  Text(
                    'Remaining: KES ${credit.remainingAmount.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
              ],
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Color _getStatusColor(Credit credit) {
    if (credit.status == 'paid') return Colors.green;
    if (credit.isOverdue) return Colors.red;
    return Colors.orange;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
