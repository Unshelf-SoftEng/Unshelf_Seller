import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ViewModels
import 'package:unshelf_seller/viewmodels/store_viewmodel.dart';
import 'package:unshelf_seller/views/balance_overview_view.dart';

// Views
import 'package:unshelf_seller/views/edit_store_schedule_view.dart';
import 'package:unshelf_seller/views/edit_store_location_view.dart';
import 'package:unshelf_seller/views/edit_store_profile_view.dart';
import 'package:unshelf_seller/authentication/views/login_view.dart';
import 'package:unshelf_seller/views/order_history_view.dart';
import 'package:unshelf_seller/views/product_analytics_view.dart';
import 'package:unshelf_seller/views/settings_view.dart';
import 'package:unshelf_seller/views/edit_user_profile_view.dart';
import 'package:unshelf_seller/views/store_analytics_view.dart';
import 'package:unshelf_seller/views/inventory_view.dart';

// Utils
import 'package:unshelf_seller/utils/colors.dart';

class StoreView extends StatefulWidget {
  const StoreView({super.key});

  @override
  State<StoreView> createState() => _StoreViewState();
}

class _StoreViewState extends State<StoreView> {
  bool _isGeneralActionsExpanded = false;

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

    if (viewModel.isLoading ||
        viewModel.storeDetails == null ||
        viewModel.userProfile == null) {
      return Scaffold(body: _buildLoading());
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStoreCard(viewModel),
              const SizedBox(height: 16),
              _buildSectionTitle('Store Management'),
              _buildStoreManagementSection(context, viewModel),
              const SizedBox(height: 20),
              _buildExpandableGeneralActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildStoreCard(StoreViewModel viewModel) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipOval(
          child: viewModel.storeDetails?.storeImageUrl == ''
              ? _buildDefaultStoreIcon()
              : Image.network(
                  viewModel.storeDetails?.storeImageUrl ?? '',
                  width: 60.0,
                  height: 60.0,
                  fit: BoxFit.cover,
                ),
        ),
        title: Text(
          viewModel.storeDetails?.storeName ?? 'Store Name',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Followers: ${viewModel.storeDetails?.storeFollowers ?? 0}'),
            Text(
                'Rating: ${viewModel.storeDetails?.storeRating?.toString() ?? '0.0'}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _navigateTo(
              EditStoreProfileView(storeDetails: viewModel.storeDetails!)),
        ),
      ),
    );
  }

  Widget _buildDefaultStoreIcon() {
    return Container(
      color: Colors.grey,
      width: 60.0,
      height: 60.0,
      child: const Icon(Icons.store, color: Colors.white, size: 30.0),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildStoreManagementSection(
      BuildContext context, StoreViewModel viewModel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          // Performance
          _buildListTile(
            Icons.analytics,
            'Store Analytics',
            'View store performance',
            () => _navigateTo(StoreAnalyticsView()),
          ),

          _buildListTile(
            Icons.analytics,
            'Product Analytics',
            'View product performance',
            () => _navigateTo(ProductAnalyticsView()),
          ),

          // Orders
          _buildListTile(
            Icons.history,
            'Order History',
            'View store orders',
            () => _navigateTo(OrderHistoryView()),
          ),

          // Inventory
          _buildListTile(
            Icons.inventory,
            'Store Inventory',
            'Manage products and stocks',
            () => _navigateTo(InventoryView()),
          ),

          // Store Settings
          _buildListTile(
            Icons.access_time,
            'Business Hours',
            'Manage business hours',
            () => _navigateTo(
                EditStoreScheduleView(storeDetails: viewModel.storeDetails!)),
          ),
          _buildListTile(
            Icons.location_on,
            'Store Location',
            'Edit store location',
            () => _navigateTo(
                EditStoreLocationView(storeDetails: viewModel.storeDetails!)),
          ),

          // Financials
          _buildListTile(
            Icons.wallet,
            'Wallet',
            'Manage your earnings',
            () => _navigateTo(const BalanceOverviewView()),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableGeneralActions(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: _isGeneralActionsExpanded,
      onExpansionChanged: (value) {
        setState(() => _isGeneralActionsExpanded = value);
      },
      leading: const Icon(Icons.settings, color: Colors.black54),
      title: const Text('General Actions',
          style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        _buildListTile(
            Icons.person,
            'User Profile',
            'View and edit your profile',
            () => _navigateTo(EditUserProfileView(
                userProfile: Provider.of<StoreViewModel>(context, listen: false)
                    .userProfile!))),
        _buildListTile(Icons.settings, 'Settings', 'Manage app settings',
            () => _navigateTo(const SettingsView())),
        _buildListTile(Icons.logout, 'Log Out', 'Sign out from your account',
            () async {
          await FirebaseAuth.instance.signOut();
          _navigateTo(LoginView(), clearStack: true);
        }),
      ],
    );
  }

  Widget _buildListTile(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title,
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
      onTap: onTap,
    );
  }

  void _navigateTo(Widget page, {bool clearStack = false}) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => page),
      (route) => !clearStack,
    );
  }
}
