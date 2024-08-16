import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/models/user_model.dart';
import 'package:unshelf_seller/viewmodels/user_profile_viewmodel.dart';

class UserProfileView extends StatelessWidget {
  final UserProfileModel userProfile;

  // Use the named parameter constructor
  UserProfileView({required this.userProfile});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UserProfileViewModel>(context);

    viewModel.initializeControllers(userProfile);

    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: viewModel.isLoading
          ? Center(child: CircularProgressIndicator())
          : viewModel.errorMessage != null
              ? Center(child: Text(viewModel.errorMessage!))
              : Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: viewModel.nameController,
                        decoration: InputDecoration(labelText: 'Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: viewModel.emailController,
                        decoration: InputDecoration(labelText: 'Email'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: viewModel.phoneController,
                        decoration: InputDecoration(labelText: 'Phone Number'),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: viewModel.passwordController,
                        obscureText: true,
                        decoration: InputDecoration(labelText: 'Password'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          } else if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: viewModel.confirmPasswordController,
                        obscureText: true,
                        decoration:
                            InputDecoration(labelText: 'Confirm Password'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          } else if (value !=
                              viewModel.passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          viewModel.updateUserProfile();

                          if (viewModel.errorMessage == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile updated successfully'),
                              ),
                            );
                          }

                          print('Passing ${viewModel.userProfile}');

                          Navigator.pop(context, viewModel.userProfile);
                        },
                        child: Text('Save Changes'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
