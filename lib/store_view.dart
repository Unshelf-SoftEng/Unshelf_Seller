import 'package:flutter/material.dart';
import 'package:unshelf_seller/models/store_model.dart';
import 'package:unshelf_seller/edit_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoreView extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  StoreView({Key? key}) : super(key: key);

  Future<StoreModel> _fetchUserProfile() async {
    if (user == null) {
      throw Exception("User is not logged in");
    }
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    return StoreModel.fromSnapshot(doc);
  }

  String formatStoreSchedule(Map<String, Map<String, String>> schedule) {
    return schedule.entries.map((entry) {
      String day = entry.key;
      Map<String, String> times = entry.value;
      String open = times['open'] ?? 'Closed';
      String close = times['close'] ?? 'Closed';
      return '$day: $open - $close';
    }).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StoreModel>(
      future: _fetchUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Loading...'),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Error'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error fetching user profile'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Retry fetching the profile
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StoreView(),
                        ),
                      );
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text('No Data'),
            ),
            body: Center(
              child: Text('No user profile found'),
            ),
          );
        }

        final userProfile = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(userProfile.storeName),
            actions: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditStoreDetailsScreen(userProfile: userProfile),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text('Email'),
                    subtitle: Text(userProfile.email ?? 'N/A'),
                    leading: Icon(Icons.email),
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text('Name'),
                    subtitle: Text(userProfile.name ?? 'N/A'),
                    leading: Icon(Icons.person),
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text('Phone Number'),
                    subtitle: Text(userProfile.phoneNumber ?? 'N/A'),
                    leading: Icon(Icons.phone),
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ExpansionTile(
                    title: Text('Store Hours'),
                    leading: Icon(Icons.access_time),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          userProfile.storeSchedule != null
                              ? formatStoreSchedule(userProfile.storeSchedule!)
                              : 'No schedule available',
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text('Store Location'),
                    subtitle: Text(userProfile.storeLocation ?? 'N/A'),
                    leading: Icon(Icons.location_on),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
