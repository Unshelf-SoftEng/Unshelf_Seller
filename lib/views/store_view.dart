import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unshelf_seller/viewmodels/store_viewmodel.dart';
import 'package:unshelf_seller/views/restock_selection_view.dart';
import 'package:unshelf_seller/views/edit_store_schedule_view.dart';
import 'package:unshelf_seller/views/edit_store_location_view.dart';
import 'package:unshelf_seller/views/edit_store_profile_view.dart';
import 'package:unshelf_seller/views/login_view.dart';
import 'package:unshelf_seller/views/settings_view.dart';
import 'package:unshelf_seller/views/user_profile_view.dart';
import 'package:unshelf_seller/models/user_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as lat_lng2;

class StoreView extends StatefulWidget {
  @override
  _StoreViewState createState() => _StoreViewState();
}

class _StoreViewState extends State<StoreView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<StoreViewModel>(context, listen: false);
      viewModel.fetchStoreDetails();
      viewModel.fetchUserProfile();
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
    return const Center(child: CircularProgressIndicator());
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
    if (viewModel.isLoading) {
      return _buildLoading();
    }

    if (viewModel.errorMessage != null) {
      return _buildError(viewModel);
    }

    // Ensure storeDetails and userProfile are initialized properly
    if (viewModel.storeDetails == null || viewModel.userProfile == null) {
      return Center(child: Text('Loading data...')); // Loading state
    }

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
            _buildSectionTitle('General'),
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
            Text('Followers: ${viewModel.storeDetails?.storeFollowers ?? 0}'),
            Text(
                'Rating: ${viewModel.storeDetails?.storeRating?.toString() ?? 0.0}'),
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
            onTap: () async {
              final updatedProfile = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UserProfileView(userProfile: viewModel.userProfile!),
                ),
              );

              if (updatedProfile != null &&
                  updatedProfile is UserProfileModel) {
                setState(() {
                  viewModel.userProfile!.name = updatedProfile.name;
                  viewModel.userProfile!.email = updatedProfile.email;
                  viewModel.userProfile!.phoneNumber =
                      updatedProfile.phoneNumber;
                });
              }
            },
          ),
          ListTile(
            title: const Text('Store Inventory'),
            subtitle: const Text('View and edit your store inventory'),
            leading: Icon(Icons.inventory),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RestockSelectionView(),
                ),
              );

              if (result == true) {
                final viewModel =
                    Provider.of<StoreViewModel>(context, listen: false);
                viewModel.fetchStoreDetails(); // Refresh store details
              }
            },
          ),
          ListTile(
            title: const Text('Store Hours'),
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
            child: FlutterMap(
              options: MapOptions(
                initialCenter: lat_lng2.LatLng(
                    viewModel.storeDetails!.storeLatitude!,
                    viewModel.storeDetails!.storeLongitude!),
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                if (viewModel.storeDetails?.storeLatitude != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: lat_lng2.LatLng(
                          viewModel.storeDetails!.storeLatitude!,
                          viewModel.storeDetails!.storeLongitude!,
                        ),
                        child: Container(
                          child: Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40.0,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          )
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
            title: Text('Help Center'),
            leading: Icon(Icons.help_outline),
            onTap: () {},
          ),
          ListTile(
            title: Text('Customer Support'),
            leading: Icon(Icons.support_agent),
            onTap: () {},
          ),
          ListTile(
            title: Text('Privacy Notice'),
            leading: Icon(Icons.privacy_tip),
            onTap: () {},
          ),
          ListTile(
            title: Text('Log Out'),
            leading: Icon(Icons.logout),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
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
