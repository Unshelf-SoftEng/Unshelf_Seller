import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unshelf_seller/components/chat_screen.dart';
import 'package:unshelf_seller/views/dashboard_view.dart';
import 'package:unshelf_seller/views/orders_view.dart';
import 'package:unshelf_seller/views/listings_view.dart';
import 'package:unshelf_seller/views/store_view.dart';
import 'package:unshelf_seller/views/wallet_view.dart';
import 'package:unshelf_seller/views/notifications_view.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _notifications = [];
  int _unseenCount = 0;

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
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('recipient_id', isEqualTo: user.uid)
        .orderBy('created_at', descending: true) // Optional: Order by timestamp
        .get();

    final notifications = snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'title': doc['title'],
        'text': doc['message'],
        'seen': doc['seen'] ?? false,
      };
    }).toList();

    // Calculate unseen count
    final unseenCount = notifications.where((n) => !n['seen']).length;

    setState(() {
      _notifications = notifications;
      _unseenCount = unseenCount;
    });
  }

  void _markNotificationAsRead(int index) async {
    // Extract the notification ID
    final notificationId = _notifications[index]['id'];

    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({'seen': true});

      setState(() {
        _notifications[index]['seen'] = true;
        _unseenCount = _unseenCount - 1;
      });
    } catch (e) {
      // Handle errors
      print('Error updating notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6A994E),
        automaticallyImplyLeading: _buildLeadingIcon() == null,
        leading: _buildLeadingIcon(),
        title: null, // Remove the default title
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationsView(),
                ),
              );
            },
            child: Stack(
              children: [
                const Icon(Icons.notifications, size: 30),
                if (_notifications.any((n) => !n['seen']))
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Center(
                        child: Text(
                          _unseenCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
        flexibleSpace: Align(
          alignment: Alignment.center, // Center the title within the AppBar
          child: Text(
            _titles[_selectedIndex],
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Container(
            color: Color(0xFFC8DD96),
            height: 4.0,
          ),
        ),
      ),
      body: _screens[_selectedIndex],
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
        unselectedItemColor: Colors.black,
        selectedItemColor: const Color(0xFF6A994E),
        onTap: _onItemTapped,
      ),
    );
  }

  Widget? _buildLeadingIcon() {
    switch (_selectedIndex) {
      case 0: // Dashboard
        return IconButton(
          icon: Icon(
            Icons.chat,
            size: 30,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(),
              ),
            );
          },
        );
      case 3: // Store
        return IconButton(
          icon: Icon(Icons.account_balance_wallet, size: 30),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => WalletView()));
          },
        );
      default:
        return null;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
