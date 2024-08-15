import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unshelf_seller/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileViewModel extends ChangeNotifier {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  UserProfileModel? userProfile;

  UserProfileViewModel({required this.userProfile});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void updateUserProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      User user = FirebaseAuth.instance.currentUser!;

      if (passwordController.text.isNotEmpty &&
          confirmPasswordController.text.isEmpty) {
        _errorMessage = 'Please confirm your password';
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (passwordController.text != confirmPasswordController.text) {
        _errorMessage = 'Passwords do not match';
        _isLoading = false;
        notifyListeners();
        return;
      }

      await FirebaseAuth.instance.currentUser!
          .updatePassword(passwordController.text);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'name': nameController.text,
        'email': emailController.text,
        'phoneNumber': phoneController.text,
      });

      userProfile = UserProfileModel(
        userId: user.uid,
        name: nameController.text,
        email: emailController.text,
        phoneNumber: phoneController.text,
        password: passwordController.text,
      );
    } catch (error) {
      _errorMessage = 'Failed to update user profile';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
