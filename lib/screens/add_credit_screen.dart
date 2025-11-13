import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/credit_provider.dart';
import '../models/credit.dart';

class AddCreditScreen extends StatefulWidget {
  @override
  _AddCreditScreenState createState() => _AddCreditScreenState();
}

class _AddCreditScreenState extends State<AddCreditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contactNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'customer';
  DateTime _selectedDate = DateTime.now().add(Duration(days: 30));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Credit'),
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Credit Type',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                      value: 'customer',
                      child: Text('Customer Credit (They owe you)')),
                  DropdownMenuItem(
                      value: 'supplier',
                      child: Text('Supplier Credit (You owe them)')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _contactNameController,
                decoration: InputDecoration(
                  labelText: 'Contact Name',
                  border: OutlineInputBorder(),
                  hintText: 'Enter customer/supplier name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount (KES)',
                  border: OutlineInputBorder(),
                  prefixText: 'KES ',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter valid amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Goods supplied, Services rendered',
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('Due Date'),
                subtitle: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveCredit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Save Credit',
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
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveCredit() async {
    if (_formKey.currentState!.validate()) {
      final credit = Credit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: _selectedType,
        contactId:
            DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
        contactName: _contactNameController.text,
        amount: double.parse(_amountController.text),
        dueDate: _selectedDate,
        createdDate: DateTime.now(),
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        status: 'pending',
      );

      try {
        await Provider.of<CreditProvider>(context, listen: false)
            .addCredit(credit);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Credit added successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding credit: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _contactNameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
