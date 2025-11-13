import 'package:flutter/material.dart';
import '../services/memory_storage_service.dart';

class BusinessProfile {
  final String businessName;
  final String businessType;
  final String contactInfo;
  final String location;
  final String? email;
  final String? phone;

  BusinessProfile({
    required this.businessName,
    required this.businessType,
    required this.contactInfo,
    required this.location,
    this.email,
    this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'businessName': businessName,
      'businessType': businessType,
      'contactInfo': contactInfo,
      'location': location,
      'email': email,
      'phone': phone,
    };
  }

  factory BusinessProfile.fromMap(Map<String, dynamic> map) {
    return BusinessProfile(
      businessName: map['businessName'] ?? 'My Business',
      businessType: map['businessType'] ?? 'Retail',
      contactInfo: map['contactInfo'] ?? '',
      location: map['location'] ?? '',
      email: map['email'],
      phone: map['phone'],
    );
  }
}

class BusinessProfileProvider with ChangeNotifier {
  BusinessProfile? _businessProfile;
  final MemoryStorageService _storageService = MemoryStorageService();

  BusinessProfile? get businessProfile => _businessProfile;

  BusinessProfileProvider() {
    loadBusinessProfile();
  }

  Future<void> loadBusinessProfile() async {
    try {
      final profileData = await _storageService.getBusinessProfile();

      if (profileData != null) {
        _businessProfile = BusinessProfile.fromMap(profileData);
      } else {
        // Create default profile if none exists
        _businessProfile = BusinessProfile(
          businessName: 'My Business',
          businessType: 'Retail',
          contactInfo: '',
          location: '',
        );
        // Save the default profile
        await _storageService.saveBusinessProfile(_businessProfile!.toMap());
      }
      notifyListeners();
    } catch (e) {
      print('Error loading business profile: $e');
      // Fallback to default profile
      _businessProfile = BusinessProfile(
        businessName: 'My Business',
        businessType: 'Retail',
        contactInfo: '',
        location: '',
      );
      notifyListeners();
    }
  }

  Future<void> saveBusinessProfile(Map<String, dynamic> profileData) async {
    try {
      _businessProfile = BusinessProfile(
        businessName: profileData['businessName'] ?? 'My Business',
        businessType: profileData['businessType'] ?? 'Retail',
        contactInfo: profileData['contactInfo'] ?? '',
        location: profileData['location'] ?? '',
        email: profileData['email'],
        phone: profileData['phone'],
      );

      // Save to storage
      await _storageService.saveBusinessProfile(_businessProfile!.toMap());

      notifyListeners();
    } catch (e) {
      print('Error saving business profile: $e');
      rethrow;
    }
  }

  Future<void> updateBusinessProfile({
    String? businessName,
    String? businessType,
    String? contactInfo,
    String? location,
    String? email,
    String? phone,
  }) async {
    try {
      _businessProfile = BusinessProfile(
        businessName:
            businessName ?? _businessProfile?.businessName ?? 'My Business',
        businessType:
            businessType ?? _businessProfile?.businessType ?? 'Retail',
        contactInfo: contactInfo ?? _businessProfile?.contactInfo ?? '',
        location: location ?? _businessProfile?.location ?? '',
        email: email ?? _businessProfile?.email,
        phone: phone ?? _businessProfile?.phone,
      );

      // Save to storage
      await _storageService.saveBusinessProfile(_businessProfile!.toMap());

      notifyListeners();
    } catch (e) {
      print('Error updating business profile: $e');
      rethrow;
    }
  }

  bool get isProfileSet {
    return _businessProfile != null &&
        _businessProfile!.businessName.isNotEmpty &&
        _businessProfile!.businessType.isNotEmpty;
  }

  // Method to clear profile (optional)
  Future<void> clearProfile() async {
    await _storageService.saveBusinessProfile({
      'businessName': 'My Business',
      'businessType': 'Retail',
      'contactInfo': '',
      'location': '',
    });
    await loadBusinessProfile(); // Reload the default profile
  }
}
