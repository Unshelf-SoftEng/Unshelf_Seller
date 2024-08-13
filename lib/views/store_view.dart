import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:unshelf_seller/viewmodels/store_viewmodel.dart';
import 'package:unshelf_seller/views/edit_store_schedule_view.dart';
import 'package:unshelf_seller/views/edit_store_location_view.dart';
import 'package:unshelf_seller/views/edit_store_profile_view.dart';
import 'package:unshelf_seller/views/login_view.dart';

class StoreView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StoreViewModel>(context);

    return Scaffold(
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
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          children: [
                            Card(
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundImage:
                                      viewModel.storeDetails?.storeImageUrl !=
                                              null
                                          ? NetworkImage(viewModel
                                              .storeDetails!.storeImageUrl!)
                                          : null,
                                ),
                                title: Text(viewModel.storeDetails?.storeName ??
                                    'Store Name'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Followers: ${viewModel.storeDetails?.storeFollowers ?? 'N/A'}'),
                                    Text(
                                        'Rating: ${viewModel.storeDetails?.storeRating?.toString() ?? 'N/A'}'),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditStoreProfileView(
                                                storeDetails:
                                                    viewModel.storeDetails!),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
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
                                subtitle:
                                    Text(viewModel.storeDetails?.name ?? 'N/A'),
                                leading: Icon(Icons.person),
                              ),
                            ),
                            Card(
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                title: Text('Phone Number'),
                                subtitle: Text(
                                    viewModel.storeDetails?.phoneNumber ??
                                        'N/A'),
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
                                        viewModel.storeDetails?.storeSchedule !=
                                                null
                                            ? viewModel.formatStoreSchedule(
                                                viewModel.storeDetails!
                                                    .storeSchedule!)
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
                                          builder: (context) =>
                                              EditStoreSchedView(
                                                  storeDetails:
                                                      viewModel.storeDetails!),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Card(
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text('Store Location'),
                                    subtitle: Text(viewModel
                                                .storeDetails!.storeLatitude !=
                                            null
                                        ? '${viewModel.storeDetails!.storeLatitude}, ${viewModel.storeDetails!.storeLongitude}'
                                        : 'N/A'),
                                    leading: Icon(Icons.location_on),
                                  ),
                                  Container(
                                    height: 100.0,
                                    child: GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                        target: viewModel.storeDetails!
                                                    .storeLatitude !=
                                                null
                                            ? LatLng(
                                                viewModel.storeDetails!
                                                    .storeLatitude!,
                                                viewModel.storeDetails!
                                                    .storeLongitude!,
                                              )
                                            : const LatLng(37.7749, -122.4194),
                                        zoom: 16.0,
                                      ),
                                      markers: viewModel.storeDetails!
                                                  .storeLatitude !=
                                              null
                                          ? {
                                              Marker(
                                                markerId:
                                                    MarkerId('storeLocation'),
                                                position: LatLng(
                                                  viewModel.storeDetails!
                                                      .storeLatitude!,
                                                  viewModel.storeDetails!
                                                      .storeLongitude!,
                                                ),
                                              ),
                                            }
                                          : {},
                                      onMapCreated:
                                          (GoogleMapController controller) {
                                        // Optionally, you can store the controller if needed
                                      },
                                      myLocationEnabled: false,
                                      zoomControlsEnabled: false,
                                      scrollGesturesEnabled: false,
                                      tiltGesturesEnabled: false,
                                      rotateGesturesEnabled: false,
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
                            SizedBox(height: 20),
                            Card(
                              child: Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.push(context, '/settings');
                                    },
                                    child: Text('Settings'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await FirebaseAuth.instance.signOut();
                                      Navigator.pushReplacementNamed(
                                          context, '/login');
                                    },
                                    child: Text('Log Out'),
                                  ),
                                ],
                              ),
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
