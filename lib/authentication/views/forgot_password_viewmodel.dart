import 'package:flutter/material.dart';

import 'package:unshelf_seller/core/base_viewmodel.dart';
import 'package:unshelf_seller/core/interfaces/i_auth_service.dart';

class ForgotPasswordViewModel extends BaseViewModel {
  final IAuthService _authService;
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ForgotPasswordViewModel({required IAuthService authService})
      : _authService = authService;

  Future<String> sendPasswordReset() async {
    if (formKey.currentState?.validate() ?? false) {
      try {
        await _authService.sendPasswordResetEmail(emailController.text);
        return 'Password reset email sent';
      } catch (e) {
        return 'Password reset failed. Please try again.';
      }
    }
    return 'Please enter a valid email.';
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
