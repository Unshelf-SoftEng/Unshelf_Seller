import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unshelf_seller/components/chat_screen.dart';
import 'package:unshelf_seller/views/dashboard_view.dart';
import 'package:unshelf_seller/views/orders_view.dart';
import 'package:unshelf_seller/views/listings_view.dart';
import 'package:unshelf_seller/views/store_view.dart';

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
    'DASHBOARD',
    'ORDERS',
    'LISTINGS',
    'PROFILE',
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

    print('Fetched ${snapshot.docs.length} notifications');

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
            PopupMenuButton<int>(
              icon: Stack(
                children: [
                  Icon(Icons.notifications, size: 30),
                  if (_notifications.any((n) => !n['seen']))
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            _unseenCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              onSelected: (value) {
                // Handle notification menu selection
                // e.g., navigate to a notifications screen
              },
              itemBuilder: (BuildContext context) {
                return _notifications.isNotEmpty
                    ? _notifications
                        .asMap()
                        .map((index, notification) => MapEntry(
                              index,
                              PopupMenuItem<int>(
                                value: index,
                                child: InkWell(
                                  onTap: () {
                                    _markNotificationAsRead(index);
                                    Navigator.pop(context);
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        notification['seen']
                                            ? Icons.check_circle
                                            : Icons.notifications,
                                        color: notification['seen']
                                            ? Colors.green
                                            : Colors.blue,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              notification['title'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: notification['seen']
                                                    ? Colors.grey
                                                    : Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              notification['text'],
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: notification['seen']
                                                    ? Colors.grey
                                                    : Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ))
                        .values
                        .toList()
                    : [
                        const PopupMenuItem<int>(
                          value: 0,
                          child: ListTile(
                            leading: Icon(Icons.notifications_off,
                                color: Colors.grey),
                            title: Text(
                              'No notifications',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ];
              },
            ),
          ],
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
        unselectedItemColor: const Color(0xFF6A994E),
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget? _buildLeadingIcon() {
    switch (_selectedIndex) {
      case 0: // Dashboard
        return IconButton(
          icon: Icon(Icons.chat),
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
          icon: Icon(Icons.account_balance_wallet),
          onPressed: () {
            // Navigate to WalletView or any other action
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
