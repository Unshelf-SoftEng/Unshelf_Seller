import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:unshelf_seller/viewmodels/store_viewmodel.dart';
import 'package:unshelf_seller/views/edit_store_schedule_view.dart';
import 'package:unshelf_seller/views/edit_store_location_view.dart';
import 'package:unshelf_seller/views/edit_store_profile_view.dart';
import 'package:unshelf_seller/views/listings_view.dart';
import 'package:unshelf_seller/views/login_view.dart';
import 'package:unshelf_seller/views/orders_view.dart';
import 'package:unshelf_seller/views/settings_view.dart';
import 'package:unshelf_seller/views/user_profile_view.dart';
import 'package:unshelf_seller/viewmodels/listing_viewmodel.dart';
import 'package:unshelf_seller/viewmodels/order_viewmodel.dart';

class StoreView extends StatefulWidget {
  @override
  _StoreViewState createState() => _StoreViewState();
}

class _StoreViewState extends State<StoreView> {
  @override
  void initState() {
    super.initState();
    // Fetch store details when the view is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<StoreViewModel>(context, listen: false);
      viewModel.fetchStoreDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StoreViewModel>(context);

    return Scaffold(
      body: viewModel.isLoading
          ? _buildLoading()
          : viewModel.errorMessage != null
              ? _buildError(viewModel)
              : _buildContent(context, viewModel),
    );
  }

  Widget _buildLoading() {
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildError(StoreViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(viewModel.errorMessage!),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final viewModel =
                  Provider.of<StoreViewModel>(context, listen: false);
              viewModel.fetchStoreDetails();
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, StoreViewModel viewModel) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStoreCard(viewModel, context),
            SizedBox(height: 16.0),
            _buildSectionTitle('Store Information'),
            _buildDetailsAndActionsSection(context, viewModel),
            SizedBox(height: 20),
            _buildSectionTitle('Management & Settings'),
            _buildGeneralActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStoreCard(StoreViewModel viewModel, BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: viewModel.storeDetails?.storeImageUrl != null
              ? NetworkImage(viewModel.storeDetails!.storeImageUrl!)
              : null,
        ),
        title: Text(viewModel.storeDetails?.storeName ?? 'Store Name'),
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
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    EditStoreProfileView(storeDetails: viewModel.storeDetails!),
              ),
            );

            if (result == true) {
              final viewModel =
                  Provider.of<StoreViewModel>(context, listen: false);
              viewModel.fetchStoreDetails(); // Refresh store details
            }
          },
        ),
      ),
    );
  }

  Widget _buildDetailsAndActionsSection(
      BuildContext context, StoreViewModel viewModel) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          ListTile(
            title: Text('User Profile'),
            subtitle: Text('View and edit your profile'),
            leading: Icon(Icons.person),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UserProfileView(), // Navigate to User Profile screen
                ),
              );
            },
          ),
          ListTile(
            title: Text('Store Hours'),
            subtitle: Text('View and edit your store hours'),
            leading: Icon(Icons.access_time),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditStoreSchedView(storeDetails: viewModel.storeDetails!),
                ),
              );
            },
          ),
          ListTile(
            title: Text('Store Location'),
            subtitle: Text('View and edit your store location'),
            leading: Icon(Icons.location_on),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditStoreLocationView(
                      storeDetails: viewModel.storeDetails!),
                ),
              );

              if (result == true) {
                final viewModel =
                    Provider.of<StoreViewModel>(context, listen: false);
                viewModel.fetchStoreDetails(); // Refresh store details
              }
            },
          ),
          Container(
            height: 100.0,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: viewModel.storeDetails?.storeLatitude != null
                    ? LatLng(viewModel.storeDetails!.storeLatitude!,
                        viewModel.storeDetails!.storeLongitude!)
                    : const LatLng(37.7749, -122.4194),
                zoom: 16.0,
              ),
              markers: viewModel.storeDetails?.storeLatitude != null
                  ? {
                      Marker(
                        markerId: MarkerId('storeLocation'),
                        position: LatLng(
                          viewModel.storeDetails!.storeLatitude!,
                          viewModel.storeDetails!.storeLongitude!,
                        ),
                      ),
                    }
                  : {},
              onMapCreated: (GoogleMapController controller) {
                // Optionally, you can store the controller if needed
              },
              myLocationEnabled: false,
              zoomControlsEnabled: false,
              scrollGesturesEnabled: false,
              tiltGesturesEnabled: false,
              rotateGesturesEnabled: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralActions(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text('Settings'),
            leading: Icon(Icons.settings),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsView(),
                ),
              );
            },
          ),
          ListTile(
            title: Text('Log Out'),
            leading: Icon(Icons.logout),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Provider.of<StoreViewModel>(context, listen: false).clear();
              Provider.of<ListingViewModel>(context, listen: false).clear();
              Provider.of<OrderViewModel>(context, listen: false).clear();

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => LoginView(),
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
