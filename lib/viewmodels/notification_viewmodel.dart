import 'package:flutter/material.dart';
import 'package:unshelf_seller/models/notification_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationViewModel extends ChangeNotifier {
  List<NotificationModel> _notifications = [];

  int _unseenCount = 0;
  int unseenCount() => _unseenCount;

  Future<void> fetchNotifications() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('recipient_id', isEqualTo: user.uid)
        .orderBy('created_at', descending: true)
        .get();

    final notifications = querySnapshot.docs.map((doc) {
      return NotificationModel.fromFirestore(
        doc.id,
        doc.data() as Map<String, dynamic>,
      );
    }).toList();

    print('Notifications: $querySnapshot');

    // Calculate unseen count
    final unseenCount = notifications.where((n) => !n.seen).length;

    // Update your variables
    _notifications = notifications;
    _unseenCount = unseenCount;
    notifyListeners();
  }

  List<NotificationModel> get notifications => _notifications;

  void _loadNotifications() {
    // Simulating fetching seller-side notifications (e.g., from a server)
    _notifications = [
      NotificationModel(
        id: '1',
        title: "New Order Received",
        text: "You have received a new order #20241018-001.",
      ),
      NotificationModel(
        id: '2',
        title: "Withdrawal Approved",
        text: "Your withdrawal request has been approved.",
      ),
      NotificationModel(
        id: '3',
        title: "Stock Expiration Alert",
        text: "Your stock of Organic Apples is nearing expiration.",
      ),
      NotificationModel(
        id: '4',
        title: "Customer Inquiry",
        text: "A customer has asked about the availability of Organic Bananas.",
      ),
      NotificationModel(
        id: '5',
        title: "Product Listed",
        text:
            "Your product: Organic Strawberries has been successfully listed.",
      ),
      NotificationModel(
        id: '6',
        title: "Sales Alert",
        text: "Your sale on Fresh Juice ends in 2 hours. Don't miss it!",
      ),
      NotificationModel(
        id: '7',
        title: "Low Stock Warning",
        text: "You have low stock on Fresh Orange Juice. Restock soon!",
      ),
      NotificationModel(
        id: '8',
        title: "Feedback Received",
        text: "You received feedback from a customer on your recent sale.",
      ),
      NotificationModel(
        id: '9',
        title: "New Promotional Campaign",
        text: "Your promotional campaign for Seasonal Fruits is now live!",
      ),
      NotificationModel(
        id: '10',
        title: "Product Review",
        text: "A customer left a review for your product: Organic Apples.",
      ),
    ];
    notifyListeners();
  }

  void markNotificationAsReadAsync(int index) async {
    // Extract the notification ID
    final notificationId = _notifications[index].id;

    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({'seen': true});

      _notifications[index].seen = true;
      _unseenCount = _unseenCount - 1;
    } catch (e) {
      // Handle errors
      print('Error updating notification: $e');
    }
  }

  // void markNotificationAsRead(int index) {
  //   if (index >= 0 && index < _notifications.length) {
  //     _notifications[index] = NotificationModel(
  //       id: _notifications[index].id,
  //       title: _notifications[index].title,
  //       text: _notifications[index].text,
  //       seen: true,
  //     );
  //     notifyListeners();
  //   }
  // }
}
