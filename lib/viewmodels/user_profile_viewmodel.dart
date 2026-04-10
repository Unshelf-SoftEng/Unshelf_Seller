import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unshelf_seller/core/base_viewmodel.dart';
import 'package:unshelf_seller/core/interfaces/i_user_profile_service.dart';
import 'package:unshelf_seller/core/service_locator.dart';
import 'package:unshelf_seller/models/user_model.dart';

class UserProfileViewModel extends BaseViewModel {
  final IUserProfileService _userProfileService;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  UserProfileModel? userProfile;

  UserProfileViewModel({
    required this.userProfile,
    IUserProfileService? userProfileService,
  }) : _userProfileService =
            userProfileService ?? locator<IUserProfileService>();

  void initializeControllers(UserProfileModel userProfile) {
    nameController.text = userProfile.name;
    emailController.text = userProfile.email;
    phoneController.text = userProfile.phoneNumber;
  }

  Future<void> updateUserProfile() async {
    await runBusyFuture(() async {
      final user = FirebaseAuth.instance.currentUser!;

      if (passwordController.text.isNotEmpty &&
          confirmPasswordController.text.isEmpty) {
        setError('Please confirm your password');
        return;
      }

      if (passwordController.text != confirmPasswordController.text) {
        setError('Passwords do not match');
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

      await _userProfileService.updateUserProfile({
        'name': nameController.text,
        'email': emailController.text,
        'phoneNumber': phoneController.text,
      });
    });
  }
}
