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

  void initializeControllers(UserProfileModel userProfile) {
    nameController.text = userProfile.name;
    emailController.text = userProfile.email;
    phoneController.text = userProfile.phoneNumber;
  }

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

      if (emailController.text != user.email) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: passwordController.text,
        );

        await user.reauthenticateWithCredential(credential);
      }

      if (passwordController.text.isNotEmpty &&
          confirmPasswordController.text.isNotEmpty) {
        await FirebaseAuth.instance.currentUser!
            .updatePassword(passwordController.text);
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'name': nameController.text,
        'email': emailController.text,
        'phoneNumber': phoneController.text,
      });

      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _errorMessage = 'Failed to update user profile: $error';
      _isLoading = false;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
