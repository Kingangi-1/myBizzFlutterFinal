import 'package:flutter/foundation.dart';

class BusinessProfileProvider with ChangeNotifier {
  String _businessName;
  String _industry;
  String _currency;
  String _fiscalYear;
  String _location;
  String _contactInfo;
  String _email;
  String _phone;

  // Getters
  String get businessName => _businessName;
  String get industry => _industry;
  String get currency => _currency;
  String get fiscalYear => _fiscalYear;
  String get location => _location;
  String get contactInfo => _contactInfo;
  String get email => _email;
  String get phone => _phone;

  // Setters
  void setBusinessName(String name) {
    _businessName = name;
    notifyListeners();
  }

  void setIndustry(String industry) {
    _industry = industry;
    notifyListeners();
  }

  void setCurrency(String currency) {
    _currency = currency;
    notifyListeners();
  }

  void setFiscalYear(String year) {
    _fiscalYear = year;
    notifyListeners();
  }

  void setLocation(String location) {
    _location = location;
    notifyListeners();
  }

  void setContactInfo(String contactInfo) {
    _contactInfo = contactInfo;
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setPhone(String phone) {
    _phone = phone;
    notifyListeners();
  }

  // Initialize with default values
  BusinessProfileProvider()
      : _businessName = 'My Business',
        _industry = 'Retail',
        _currency = 'KES',
        _fiscalYear = '2024',
        _location = '',
        _contactInfo = '',
        _email = '',
        _phone = '';

  // Method to save to storage (for future implementation)
  Future<void> saveToStorage() async {
    // TODO: Implement saving to shared_preferences or database
    print('Business profile saved to storage');
  }

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'businessName': _businessName,
      'industry': _industry,
      'currency': _currency,
      'fiscalYear': _fiscalYear,
      'location': _location,
      'contactInfo': _contactInfo,
      'email': _email,
      'phone': _phone,
    };
  }

  // Create from map
  factory BusinessProfileProvider.fromMap(Map<String, dynamic> map) {
    final provider = BusinessProfileProvider();
    provider._businessName = map['businessName'] ?? 'My Business';
    provider._industry = map['industry'] ?? 'Retail';
    provider._currency = map['currency'] ?? 'KES';
    provider._fiscalYear = map['fiscalYear'] ?? '2024';
    provider._location = map['location'] ?? '';
    provider._contactInfo = map['contactInfo'] ?? '';
    provider._email = map['email'] ?? '';
    provider._phone = map['phone'] ?? '';
    return provider;
  }
}
