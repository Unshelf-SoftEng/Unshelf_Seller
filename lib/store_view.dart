import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/models/store_model.dart';
import 'package:unshelf_seller/edit_store_schedule_view.dart';
import 'package:unshelf_seller/edit_store_location_view.dart';

class StoreView extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  StoreView({Key? key}) : super(key: key);

  Future<StoreModel> _fetchStoreDetails() async {
    if (user == null) {
      throw Exception("User is not logged in");
    }

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    if (!doc.exists) {
      throw Exception("User profile not found");
    }

    return StoreModel.fromSnapshot(doc);
  }

  String formatStoreSchedule(Map<String, Map<String, String>> schedule) {
    const List<String> daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return daysOfWeek.map((day) {
      Map<String, String> times =
          schedule[day] ?? {'open': 'Closed', 'close': 'Closed'};
      String open = times['open'] ?? 'Closed';
      String close = times['close'] ?? 'Closed';
      if (open == 'Closed' && close == 'Closed') {
        return '$day: Closed';
      } else {
        return '$day: $open - $close';
      }
    }).join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StoreModel>(
      future: _fetchStoreDetails(),
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

        final storeDetails = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(storeDetails.storeName),
          ),
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                      title: Text('Email'),
                      subtitle: Text(storeDetails.email ?? 'N/A'),
                      leading: Icon(Icons.email)),
                ),
                Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text('Name'),
                    subtitle: Text(storeDetails.name ?? 'N/A'),
                    leading: Icon(Icons.person),
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text('Phone Number'),
                    subtitle: Text(storeDetails.phoneNumber ?? 'N/A'),
                    leading: Icon(Icons.phone),
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Text('Store Hours'),
                          subtitle: Text(
                            storeDetails.storeSchedule != null
                                ? formatStoreSchedule(
                                    storeDetails.storeSchedule!)
                                : 'No schedule available',
                          ),
                          leading: Icon(Icons.access_time),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditStoreSchedScreen(
                                  storeDetails: storeDetails),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Text('Store Location'),
                          subtitle: Text(storeDetails.storeLocation ?? 'N/A'),
                          leading: Icon(Icons.location_on),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditStoreLocationView(),
                            ),
                          );
                        },
                      ),
                    ],
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
