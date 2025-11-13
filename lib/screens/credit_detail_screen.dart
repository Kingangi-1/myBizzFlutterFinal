import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/credit.dart';
import '../providers/credit_provider.dart';
import 'add_payment_screen.dart';

class CreditDetailScreen extends StatelessWidget {
  final Credit credit;

  const CreditDetailScreen({required this.credit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Credit Details'),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: Icon(Icons.payment),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddPaymentScreen(credit: credit),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            SizedBox(height: 16),
            _buildPaymentsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  credit.contactName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(credit),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    credit.statusDisplay.toUpperCase(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
                '${credit.type == 'customer' ? 'Customer' : 'Supplier'} Credit',
                style: TextStyle(color: Colors.grey)),
            SizedBox(height: 16),
            Row(
              children: [
                _buildInfoItem(
                    'Total Amount', 'KES ${credit.amount.toStringAsFixed(2)}'),
                _buildInfoItem('Remaining',
                    'KES ${credit.remainingAmount.toStringAsFixed(2)}'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                _buildInfoItem('Due Date', _formatDate(credit.dueDate)),
                _buildInfoItem('Created', _formatDate(credit.createdDate)),
              ],
            ),
            if (credit.description != null) ...[
              SizedBox(height: 8),
              Text('Description: ${credit.description!}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPaymentsSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          if (credit.payments.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.payment, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No payments recorded',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: credit.payments.length,
                itemBuilder: (context, index) {
                  final payment = credit.payments[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Icon(Icons.payment, color: Colors.green),
                      title: Text('KES ${payment.amount.toStringAsFixed(2)}'),
                      subtitle: Text(
                          '${payment.method} • ${_formatDate(payment.paymentDate)}'),
                      trailing: payment.reference != null
                          ? Text(payment.reference!)
                          : null,
                    ),
                  );
                },
              ),
            ),
        ],
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
