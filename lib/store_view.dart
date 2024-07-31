import 'package:flutter/material.dart';
import 'package:unshelf_seller/models/user_model.dart';
import 'package:unshelf_seller/edit_profile_screen.dart';

class StoreView extends StatelessWidget {
  final UserProfile userProfile; // Receive user profile data

  const StoreView({Key? key, required this.userProfile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold is the root to add the app bar
      appBar: AppBar(
        title: Text(userProfile.storeName),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditProfileScreen(userProfile: userProfile),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Email: ${userProfile.email}'),
            Text('Name: ${userProfile.name}'),
            Text('Phone Number: ${userProfile.phoneNumber}'),
            Text('Store Hours: ${userProfile.storeHours}'), // New fields
            Text('Store Location: ${userProfile.storeLocation}'),
          ],
        ),
      ),
    );
  }
}
