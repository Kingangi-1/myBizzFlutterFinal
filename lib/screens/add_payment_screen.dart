import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/credit.dart';
import '../providers/credit_provider.dart';

class AddPaymentScreen extends StatefulWidget {
  final Credit credit;

  const AddPaymentScreen({required this.credit});

  @override
  _AddPaymentScreenState createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();

  String _selectedMethod = 'cash';
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Payment'),
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Credit Details',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Contact: ${widget.credit.contactName}'),
                      Text(
                          'Remaining: KES ${widget.credit.remainingAmount.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Payment Amount (KES)',
                  border: OutlineInputBorder(),
                  prefixText: 'KES ',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null) {
                    return 'Please enter valid amount';
                  }
                  if (amount > widget.credit.remainingAmount) {
                    return 'Amount cannot exceed remaining balance';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedMethod,
                decoration: InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'mpesa', child: Text('M-Pesa')),
                  DropdownMenuItem(value: 'bank', child: Text('Bank Transfer')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedMethod = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _referenceController,
                decoration: InputDecoration(
                  labelText: 'Reference (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., M-Pesa code, transaction ID',
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('Payment Date'),
                subtitle: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _savePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Record Payment',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _savePayment() async {
    if (_formKey.currentState!.validate()) {
      final payment = PaymentRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        creditId: widget.credit.id,
        paymentDate: _selectedDate,
        amount: double.parse(_amountController.text),
        method: _selectedMethod,
        reference: _referenceController.text.isEmpty
            ? null
            : _referenceController.text,
      );

      try {
        await Provider.of<CreditProvider>(context, listen: false)
            .addPayment(widget.credit.id, payment);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment recorded successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error recording payment: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }
}
