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
  final _businessTypeController = TextEditingController();
  final _contactInfoController = TextEditingController();
  final _locationController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessProfileProvider>().loadBusinessProfile();
    });
  }

  void _updateControllers(BusinessProfile profile) {
    _businessNameController.text = profile.businessName;
    _businessTypeController.text = profile.businessType;
    _contactInfoController.text = profile.contactInfo;
    _locationController.text = profile.location;
    _emailController.text = profile.email ?? '';
    _phoneController.text = profile.phone ?? '';
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final profileData = {
        'businessName': _businessNameController.text,
        'businessType': _businessTypeController.text,
        'contactInfo': _contactInfoController.text,
        'location': _locationController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
      };

      await context
          .read<BusinessProfileProvider>()
          .saveBusinessProfile(profileData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Business profile saved successfully!')),
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
      body: Consumer<BusinessProfileProvider>(
        builder: (context, businessProvider, child) {
          if (businessProvider.businessProfile != null) {
            _updateControllers(businessProvider.businessProfile!);
          }

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _businessNameController,
                    decoration: InputDecoration(
                      labelText: 'Business Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter business name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _businessTypeController,
                    decoration: InputDecoration(
                      labelText: 'Business Type',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter business type';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _contactInfoController,
                    decoration: InputDecoration(
                      labelText: 'Contact Information',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Save Profile',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessTypeController.dispose();
    _contactInfoController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
