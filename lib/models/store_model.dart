import 'package:cloud_firestore/cloud_firestore.dart';

class StoreModel {
  final String userId;
  final String email;
  final String name;
  final String phoneNumber;
  final String storeName;
  double? storeLongitude;
  double? storeLatitude;
  String? storeAddress;
  String? storePhoneNumber;
  final Map<String, Map<String, Object>>? storeSchedule;
  final String? storeImageUrl; // Nullable
  double? storeRating;
  int? storeFollowers;

  StoreModel({
    required this.userId,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.storeName,
    this.storeSchedule,
    this.storeLongitude,
    this.storeLatitude,
    this.storeImageUrl,
    this.storeRating,
    this.storeFollowers,
  });

  // Factory method to create StoreModel from Firebase document snapshot
  factory StoreModel.fromSnapshot(
      DocumentSnapshot userDoc, DocumentSnapshot storeDoc) {
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
    Map<String, dynamic> storeData = storeDoc.data() as Map<String, dynamic>;

    var printStore = storeData['storeSchedule'];

    printStore.forEach((key, value) {
      print("Day: $key");
      (value as Map<String, dynamic>).forEach((k, v) {
        print("  $k: $v");
      });
    });

    return StoreModel(
      userId: userDoc.id,
      email: userData['email'] ?? '',
      name: userData['name'] ?? '',
      phoneNumber: userData['phoneNumber'] ?? '',
      storeName: storeData['storeName'] ?? '',
      storeSchedule: (storeData['storeSchedule'] as Map<String, dynamic>?)?.map(
        (key, value) {
          // Handle the nested map and include the isOpen boolean
          var updatedValue = (value as Map<String, dynamic>).map(
            (k, v) {
              if (k == 'isOpen') {
                // Cast isOpen value as boolean
                return MapEntry(k, v as bool);
              }
              // Otherwise, keep the existing string value
              return MapEntry(k, v as String);
            },
          );

          return MapEntry(key, updatedValue);
        },
      ),
      storeLongitude: storeData['longitude'] ?? 0.0,
      storeLatitude: storeData['latitude'] ?? 0.0,
      storeImageUrl: storeData['storeImageUrl'] ?? '',
      storeRating: storeData['rating'] ?? 0.0,
      storeFollowers: storeData['followerCount'] ?? 0,
    );
  }
}
