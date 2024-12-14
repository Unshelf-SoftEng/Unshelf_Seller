import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  String userId;
  String name;
  String email;
  String phoneNumber;
  String? password;

  UserProfileModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.password,
  });

  factory UserProfileModel.fromSnapshot(DocumentSnapshot userDoc) {
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

    return UserProfileModel(
      userId: userDoc.id,
      email: userData['email'] ?? '',
      name: userData['name'] ?? '',
      phoneNumber: userData['phoneNumber'] ?? '',
      password: userData['password'] ?? '',
    );
  }
}
