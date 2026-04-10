import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  final String userId;
  final String name;
  final String email;
  final String phoneNumber;
  final String? password;

  UserProfileModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }

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
