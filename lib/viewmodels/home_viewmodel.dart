import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:unshelf_seller/core/base_viewmodel.dart';
import 'package:unshelf_seller/core/constants/firestore_constants.dart';
import 'package:unshelf_seller/models/notification_model.dart';

class HomeViewModel extends BaseViewModel {
  List<NotificationModel> _notifications = [];
  int _unseenCount = 0;
  int get unseenCount => _unseenCount;
  List<NotificationModel> get notifications => _notifications;

  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> fetchNotifications() async {
    await runBusyFuture(() async {
      final querySnapshot = await FirebaseFirestore.instance
          .collection(FirestoreConstants.notifications)
          .where('recipient_id', isEqualTo: user!.uid)
          .orderBy('created_at', descending: true)
          .get();

      final notifications = querySnapshot.docs.map((doc) {
        return NotificationModel.fromFirestore(
          doc.id,
          doc.data(),
        );
      }).toList();

      final unseenCount = notifications.where((n) => !n.seen).length;

      _notifications = notifications;
      _unseenCount = unseenCount;
    });
  }
}
