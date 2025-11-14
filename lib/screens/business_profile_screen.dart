import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/business_profile_provider.dart';

class BusinessProfileScreen extends StatefulWidget {
  @override
  _BusinessProfileScreenState createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _industryController = TextEditingController();
  final _currencyController = TextEditingController();
  final _fiscalYearController = TextEditingController();
  final _contactInfoController = TextEditingController();
  final _locationController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentProfile();
    });
  }

  void _loadCurrentProfile() {
    final profile = context.read<BusinessProfileProvider>();
    _businessNameController.text = profile.businessName;
    _industryController.text = profile.industry;
    _currencyController.text = profile.currency;
    _fiscalYearController.text = profile.fiscalYear;
    // Initialize other fields with empty values or add them to your provider
    _contactInfoController.text = '';
    _locationController.text = '';
    _emailController.text = '';
    _phoneController.text = '';
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<BusinessProfileProvider>();

      // Update the profile using the provider's setter methods
      provider.setBusinessName(_businessNameController.text);
      provider.setIndustry(_industryController.text);
      provider.setCurrency(_currencyController.text);
      provider.setFiscalYear(_fiscalYearController.text);

      // Save to storage if implemented
      await provider.saveToStorage();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Business profile saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Business Profile'),
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Business Name
              TextFormField(
                controller: _businessNameController,
                decoration: InputDecoration(
                  labelText: 'Business Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter business name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Industry/Business Type
              TextFormField(
                controller: _industryController,
                decoration: InputDecoration(
                  labelText: 'Industry *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work),
                  hintText: 'e.g., Retail, Services, Manufacturing',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter industry';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Currency
              TextFormField(
                controller: _currencyController,
                decoration: InputDecoration(
                  labelText: 'Currency *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_exchange),
                  hintText: 'e.g., KES, USD, EUR',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter currency';
                  }
                  if (value.length != 3) {
                    return 'Currency code must be 3 letters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Fiscal Year
              TextFormField(
                controller: _fiscalYearController,
                decoration: InputDecoration(
                  labelText: 'Fiscal Year *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                  hintText: 'e.g., 2024',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter fiscal year';
                  }
                  if (!RegExp(r'^\d{4}$').hasMatch(value)) {
                    return 'Please enter valid year (e.g., 2024)';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              SizedBox(height: 16),

              // Contact Information
              TextFormField(
                controller: _contactInfoController,
                decoration: InputDecoration(
                  labelText: 'Contact Information',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.contact_page),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Save Profile',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),

              // Info Card
              SizedBox(height: 16),
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue[700]),
                          SizedBox(width: 8),
                          Text(
                            'Profile Information',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your business profile helps customize reports and analytics. '
                        'Required fields are marked with *.',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _industryController.dispose();
    _currencyController.dispose();
    _fiscalYearController.dispose();
    _contactInfoController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
