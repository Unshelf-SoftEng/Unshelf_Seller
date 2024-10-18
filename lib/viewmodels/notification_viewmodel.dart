import 'package:flutter/material.dart';
import 'package:unshelf_seller/models/notification_model.dart';

class NotificationViewModel extends ChangeNotifier {
  List<NotificationModel> _notifications = [];

  NotificationViewModel() {
    _loadNotifications();
  }

  List<NotificationModel> get notifications => _notifications;

  int get unseenCount => _notifications.where((n) => !n.seen).length;

  void _loadNotifications() {
    // Simulating fetching seller-side notifications (e.g., from a server)
    _notifications = [
      NotificationModel(
        title: "New Order Received",
        text: "You have received a new order #20241018-001.",
      ),
      NotificationModel(
        title: "Withdrawal Approved",
        text: "Your withdrawal request has been approved.",
      ),
      NotificationModel(
        title: "Stock Expiration Alert",
        text: "Your stock of Organic Apples is nearing expiration.",
      ),
      NotificationModel(
        title: "Customer Inquiry",
        text: "A customer has asked about the availability of Organic Bananas.",
      ),
      NotificationModel(
        title: "Product Listed",
        text:
            "Your product: Organic Strawberries has been successfully listed.",
      ),
      NotificationModel(
        title: "Sales Alert",
        text: "Your sale on Fresh Juice ends in 2 hours. Don't miss it!",
      ),
      NotificationModel(
        title: "Low Stock Warning",
        text: "You have low stock on Fresh Orange Juice. Restock soon!",
      ),
      NotificationModel(
        title: "Feedback Received",
        text: "You received feedback from a customer on your recent sale.",
      ),
      NotificationModel(
        title: "New Promotional Campaign",
        text: "Your promotional campaign for Seasonal Fruits is now live!",
      ),
      NotificationModel(
        title: "Product Review",
        text: "A customer left a review for your product: Organic Apples.",
      ),
    ];
    notifyListeners();
  }

  void markNotificationAsRead(int index) {
    if (index >= 0 && index < _notifications.length) {
      _notifications[index] = NotificationModel(
        title: _notifications[index].title,
        text: _notifications[index].text,
        seen: true,
      );
      notifyListeners();
    }
  }
}
