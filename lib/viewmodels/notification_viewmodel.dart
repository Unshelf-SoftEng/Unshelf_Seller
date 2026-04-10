import 'package:unshelf_seller/models/notification_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/core/base_viewmodel.dart';
import 'package:unshelf_seller/core/logger.dart';
import 'package:unshelf_seller/core/constants/firestore_constants.dart';

class NotificationViewModel extends BaseViewModel {
  List<NotificationModel> _notifications = [];

  int _unseenCount = 0;
  int unseenCount() => _unseenCount;

  Future<void> fetchNotifications() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final querySnapshot = await FirebaseFirestore.instance
        .collection(FirestoreConstants.notifications)
        .where('recipient_id', isEqualTo: user.uid)
        .orderBy('created_at', descending: true)
        .get();

    final notifications = querySnapshot.docs.map((doc) {
      return NotificationModel.fromFirestore(
        doc.id,
        doc.data(),
      );
    }).toList();

    AppLogger.debug('Notifications fetched: ${querySnapshot.docs.length}');

    // Calculate unseen count
    final unseenCount = notifications.where((n) => !n.seen).length;

    // Update your variables
    _notifications = notifications;
    _unseenCount = unseenCount;
    notifyListeners();
  }

  List<NotificationModel> get notifications => _notifications;

  void markNotificationAsReadAsync(int index) async {
    // Extract the notification ID
    final notificationId = _notifications[index].id;

    try {
      await FirebaseFirestore.instance
          .collection(FirestoreConstants.notifications)
          .doc(notificationId)
          .update({'seen': true});

      _notifications[index].seen = true;
      _unseenCount = _unseenCount - 1;
    } catch (e) {
      // Handle errors
      AppLogger.error('Error updating notification: $e');
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
