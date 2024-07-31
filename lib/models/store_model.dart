import 'package:cloud_firestore/cloud_firestore.dart';

class StoreModel {
  final String userId;
  final String email;
  final String name;
  final String phoneNumber;
  final String storeName;
  final String? storeLocation; // Nullable
  final Map<String, Map<String, String>>? storeSchedule;

  StoreModel({
    required this.userId,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.storeName,
    this.storeSchedule,
    this.storeLocation,
  });

  // Factory method to create StoreModel from Firebase document snapshot
  factory StoreModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return StoreModel(
      userId: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phoneNumber: data['phone_number'] ?? '',
      storeName: data['store_name'] ?? '',
      storeSchedule: (data['store_schedule'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(
          key,
          (value as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, v as String),
          ),
        ),
      ),
      storeLocation: data['store_location'],
    );
  }
}
