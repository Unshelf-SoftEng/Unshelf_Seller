import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String email;
  final String name;
  final String phoneNumber;
  final String storeName;
  final String? storeHours; // New field
  final String? storeLocation; // New field

  UserProfile({
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.storeName,
    this.storeHours,
    this.storeLocation,
  });

  // Add a factory method to create a UserProfile from a Firebase document snapshot if needed

  // Factory method to create UserProfile from Firebase document snapshot
  factory UserProfile.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      email: data['email'],
      name: data['name'],
      phoneNumber: data['phone_number'],
      storeName: data['store_name'],
      storeHours: data['store_hours'], // May be null
      storeLocation: data['store_location'], // May be null
    );
  }
}
