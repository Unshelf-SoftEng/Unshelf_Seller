import 'package:flutter/material.dart';
import 'package:unshelf_seller/dashboard_view.dart';
import 'package:unshelf_seller/orders_view.dart';
import 'package:unshelf_seller/listings_view.dart';
import 'package:unshelf_seller/store_view.dart';
import 'package:unshelf_seller/add_product_details_view.dart';
import 'package:unshelf_seller/wallet_view.dart';

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
    'Dashboard',
    'Orders',
    'Listings',
    'Store',
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
                child: Text(_titles[_selectedIndex]),
              ),
            ),
            if (_selectedIndex == 2)
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddProductDetailsView(
                              productId: null,
                            )),
                  );
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
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}
