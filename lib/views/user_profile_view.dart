import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/user_profile_viewmodel.dart';

class UserProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UserProfileViewModel>(context);
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
                      TextField(
                        controller: viewModel.nameController,
                        decoration: InputDecoration(labelText: 'Name'),
                      ),
                      TextField(
                        controller: viewModel.emailController,
                        decoration: InputDecoration(labelText: 'Email'),
                      ),
                      TextField(
                        controller: viewModel.phoneController,
                        decoration: InputDecoration(labelText: 'Phone Number'),
                      ),
                      TextField(
                        controller: viewModel.passwordController,
                        obscureText: true,
                        decoration: InputDecoration(labelText: 'Password'),
                      ),
                      TextField(
                        controller: viewModel.confirmPasswordController,
                        obscureText: true,
                        decoration:
                            InputDecoration(labelText: 'Confirm Password'),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          viewModel.updateUserProfile();

                          if (viewModel.errorMessage == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Profile updated successfully'),
                              ),
                            );
                          }
                          Navigator.pop(context);
                        },
                        child: Text('Save Changes'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
