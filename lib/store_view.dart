import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unshelf_seller/viewmodels/store_viewmodel.dart';
import 'package:unshelf_seller/edit_store_schedule_view.dart';
import 'package:unshelf_seller/edit_store_location_view.dart';

class StoreView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StoreViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.storeDetails?.storeName ?? 'Store View'),
      ),
      body: viewModel.isLoading
          ? Center(child: CircularProgressIndicator())
          : viewModel.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(viewModel.errorMessage!),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          viewModel.fetchStoreDetails();
                        },
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      if (viewModel.storeDetails?.storeProfilePictureUrl !=
                          null)
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                              viewModel.storeDetails!.storeProfilePictureUrl!),
                        ),
                      SizedBox(height: 16.0),
                      Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text('Email'),
                          subtitle: Text(
                              FirebaseAuth.instance.currentUser?.email ??
                                  'N/A'),
                          leading: Icon(Icons.email),
                        ),
                      ),
                      Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text('Name'),
                          subtitle: Text(viewModel.storeDetails?.name ?? 'N/A'),
                          leading: Icon(Icons.person),
                        ),
                      ),
                      Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text('Phone Number'),
                          subtitle: Text(
                              viewModel.storeDetails?.phoneNumber ?? 'N/A'),
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
                                  viewModel.storeDetails?.storeSchedule != null
                                      ? viewModel.formatStoreSchedule(viewModel
                                          .storeDetails!.storeSchedule!)
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
                                        storeDetails: viewModel.storeDetails!),
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
                                subtitle: Text(
                                    viewModel.storeDetails?.storeLocation ??
                                        'N/A'),
                                leading: Icon(Icons.location_on),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditStoreLocationView(),
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
                                title: Text('Store Rating'),
                                subtitle: Text(viewModel
                                        .storeDetails?.storeRating
                                        .toString() ??
                                    'N/A'),
                                leading: Icon(Icons.location_on),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditStoreLocationView(),
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
                                title: Text('Store Followers'),
                                subtitle: Text(viewModel
                                        .storeDetails?.storeFollowers
                                        .toString() ??
                                    'N/A'),
                                leading: Icon(Icons.location_on),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditStoreLocationView(),
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
  }
}
