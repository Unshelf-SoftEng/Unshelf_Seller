import 'package:flutter/material.dart';
import 'package:unshelf_seller/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unshelf_seller/core/base_viewmodel.dart';
import 'package:unshelf_seller/core/constants/firestore_constants.dart';

class UserProfileViewModel extends BaseViewModel {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  UserProfileModel? userProfile;

  UserProfileViewModel({required this.userProfile});

  String? _errorMessage;
  String? get errorMessageLocal => _errorMessage;

  void initializeControllers(UserProfileModel userProfile) {
    nameController.text = userProfile.name;
    emailController.text = userProfile.email;
    phoneController.text = userProfile.phoneNumber;
  }

  void updateUserProfile() async {
    setLoading(true);

    try {
      User user = FirebaseAuth.instance.currentUser!;

      if (passwordController.text.isNotEmpty &&
          confirmPasswordController.text.isEmpty) {
        _errorMessage = 'Please confirm your password';
        setLoading(false);
        return;
      }

      if (passwordController.text != confirmPasswordController.text) {
        _errorMessage = 'Passwords do not match';
        setLoading(false);
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
          .collection(FirestoreConstants.users)
          .doc(user.uid)
          .update({
        'name': nameController.text,
        'email': emailController.text,
        'phoneNumber': phoneController.text,
      });

      setLoading(false);
    } catch (error) {
      _errorMessage = 'Failed to update user profile: $error';
      setLoading(false);
    } finally {
      setLoading(false);
    }
  }
}
