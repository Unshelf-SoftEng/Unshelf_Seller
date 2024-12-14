import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unshelf_seller/viewmodels/store_viewmodel.dart';
import 'package:unshelf_seller/views/restock_selection_view.dart';
import 'package:unshelf_seller/views/edit_store_schedule_view.dart';
import 'package:unshelf_seller/views/edit_store_location_view.dart';
import 'package:unshelf_seller/views/edit_store_profile_view.dart';
import 'package:unshelf_seller/authentication/views/login_view.dart';
import 'package:unshelf_seller/views/order_history_view.dart';
import 'package:unshelf_seller/views/settings_view.dart';
import 'package:unshelf_seller/views/edit_user_profile_view.dart';
import 'package:unshelf_seller/models/user_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as lat_lng2;
import 'package:unshelf_seller/utils/colors.dart';

class StoreView extends StatefulWidget {
  const StoreView({super.key});

  @override
  State<StoreView> createState() => _StoreViewState();
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

    if (viewModel.isLoading) {
      return Scaffold(
        body: _buildLoading(),
      );
    }

    if (viewModel.storeDetails == null || viewModel.userProfile == null) {
      return Scaffold(
        body: _buildLoading(),
      );
    }

    return Scaffold(
      body: _buildContent(context, viewModel),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildContent(BuildContext context, StoreViewModel viewModel) {
    if (viewModel.isLoading) {
      return _buildLoading();
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStoreCard(viewModel, context),
            const SizedBox(height: 16.0),
            _buildSectionTitle('Store Information'),
            _buildDetailsAndActionsSection(context, viewModel),
            const SizedBox(height: 20),
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
        style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStoreCard(StoreViewModel viewModel, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: ClipOval(
          child: viewModel.storeDetails?.storeImageUrl == ''
              ? Container(
                  color: Colors
                      .grey, // Set the background color to gray if no image is available
                  width: 60.0,
                  height: 60.0,
                  child: const Icon(
                    Icons.store, // Optional: Show a default icon if no image
                    color: Colors.white,
                    size: 30.0,
                  ),
                )
              : Image.network(
                  viewModel.storeDetails?.storeImageUrl ?? '',
                  width: 60.0,
                  height: 60.0,
                  fit: BoxFit.cover,
                ),
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
          icon: const Icon(Icons.edit),
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
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          ListTile(
            title: const Text('User Profile'),
            subtitle: const Text('View and edit your profile'),
            leading: const Icon(Icons.person),
            onTap: () async {
              final updatedProfile = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditUserProfileView(userProfile: viewModel.userProfile!),
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
            title: const Text('Order History'),
            subtitle: const Text('View all orders placed in your store'),
            leading: const Icon(Icons.history),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrderHistoryView()),
              );
            },
          ),
          ListTile(
            title: const Text('Store Inventory'),
            subtitle: const Text('View and edit your store inventory'),
            leading: const Icon(Icons.inventory),
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
            title: const Text('Business Hours'),
            subtitle: const Text('View and edit your business hours'),
            leading: const Icon(Icons.access_time),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditStoreScheduleView(
                      storeDetails: viewModel.storeDetails!),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Store Location'),
            subtitle: const Text('View and edit your store location'),
            leading: const Icon(Icons.location_on),
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
          SizedBox(
            height: 100.0,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: lat_lng2.LatLng(
                    viewModel.storeDetails!.storeLatitude!,
                    viewModel.storeDetails!.storeLongitude!),
                initialZoom: 15.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                if (viewModel.storeDetails?.storeLatitude != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: lat_lng2.LatLng(
                          viewModel.storeDetails!.storeLatitude!,
                          viewModel.storeDetails!.storeLongitude!,
                        ),
                        child: const Icon(
                          Icons.location_pin,
                          color: AppColors.watermelonRed,
                          size: 40.0,
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
            title: const Text('Settings'),
            leading: const Icon(Icons.settings),
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
            title: const Text('Help Center'),
            leading: const Icon(Icons.help_outline),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Customer Support'),
            leading: const Icon(Icons.support_agent),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Privacy Notice'),
            leading: const Icon(Icons.privacy_tip),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Log Out'),
            leading: const Icon(Icons.logout),
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
