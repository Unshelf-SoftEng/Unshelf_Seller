import 'package:flutter/material.dart';
import 'package:unshelf_seller/services/authentication_service.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final AuthService _authService;
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ForgotPasswordViewModel({required AuthService authService})
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
