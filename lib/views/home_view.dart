import 'package:flutter/material.dart';
import 'package:unshelf_seller/views/dashboard_view.dart';
import 'package:unshelf_seller/views/orders_view.dart';
import 'package:unshelf_seller/views/listings_view.dart';
import 'package:unshelf_seller/views/store_view.dart';
import 'package:unshelf_seller/views/add_product_details_view.dart';
import 'package:unshelf_seller/views/add_bundle_view.dart';
import 'package:unshelf_seller/views/batch_restock_view.dart';
import 'package:unshelf_seller/views/wallet_view.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  // List of screens to display
  final List<Widget> _screens = [
    DashboardView(),
    OrdersView(),
    ListingsView(),
    StoreView(),
  ];

  final List<String> _titles = [
    'DASHBOARD',
    'ORDERS',
    'LISTINGS',
    'PROFILE',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget? _buildLeadingIcon() {
    switch (_selectedIndex) {
      case 0: // Dashboard
        return IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            // Handle search action
          },
        );
      case 3: // Store
        return IconButton(
          icon: Icon(Icons.account_balance_wallet),
          onPressed: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => WalletView()),
            // );
          },
        );
      default:
        return null; // Return an empty container for other screens
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6A994E),
        automaticallyImplyLeading: _buildLeadingIcon() == null,
        leading: _buildLeadingIcon(),
        title: Row(
          children: <Widget>[
            Expanded(
              child: Center(
                child: Text(
                  _titles[_selectedIndex],
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (_selectedIndex == 2)
              PopupMenuButton<String>(
                icon: Icon(Icons.add),
                onSelected: (value) {
                  switch (value) {
                    case 'add_product':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddProductDetailsView(),
                        ),
                      );
                      break;
                    case 'add_bundle':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddBundleView(),
                        ),
                      );
                      break;
                    case 'batch_restock':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BatchRestockView(),
                        ),
                      );
                      break;
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'add_product',
                      child: Text('Add Product'),
                    ),
                    PopupMenuItem<String>(
                      value: 'add_bundle',
                      child: Text('Add Bundle'),
                    ),
                    // Add other options as needed
                  ];
                },
              )
            else
              PopupMenuButton<int>(
                icon: const Icon(Icons.notifications),
                onSelected: (value) {
                  // Handle notification menu selection
                  // e.g., navigate to a notifications screen
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<int>(
                      value: 1,
                      child: Text('Notification 1'),
                    ),
                    const PopupMenuItem<int>(
                      value: 2,
                      child: Text('Notification 2'),
                    ),
                    const PopupMenuItem<int>(
                      value: 3,
                      child: Text('Notification 3'),
                    ),
                  ];
                },
              ),
          ],
        ),
      ),
      body: _screens[_selectedIndex], // Display the selected screen
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Store',
          ),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: const Color(0xFF6A994E),
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}
