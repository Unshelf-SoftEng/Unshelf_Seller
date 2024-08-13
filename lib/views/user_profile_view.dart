import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/user_profile_viewmodel.dart';
import 'package:unshelf_seller/models/user_model.dart';

class UserProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UserProfileViewModel>(context);
    final nameController =
        TextEditingController(text: viewModel.userProfile.name);
    final emailController =
        TextEditingController(text: viewModel.userProfile.email);
    final phoneController =
        TextEditingController(text: viewModel.userProfile.phoneNumber);
    final passwordController = TextEditingController();

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
                        controller: nameController,
                        decoration: InputDecoration(labelText: 'Name'),
                      ),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(labelText: 'Email'),
                      ),
                      TextField(
                        controller: phoneController,
                        decoration: InputDecoration(labelText: 'Phone Number'),
                      ),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(labelText: 'Password'),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          final updatedProfile = UserProfileModel(
                            name: nameController.text,
                            email: emailController.text,
                            phoneNumber: phoneController.text,
                            password: passwordController.text.isNotEmpty
                                ? passwordController.text
                                : viewModel.userProfile.password,
                          );
                          viewModel.updateUserProfile(updatedProfile);
                        },
                        child: Text('Save Changes'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
