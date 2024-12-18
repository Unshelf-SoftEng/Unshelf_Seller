import 'package:flutter/material.dart';
import 'package:unshelf_seller/models/notification_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeViewModel extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  int _unseenCount = 0;
  int get unseenCount => _unseenCount;
  List<NotificationModel> get notifications => _notifications;

  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> fetchNotifications() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('recipient_id', isEqualTo: user!.uid)
        .orderBy('created_at', descending: true)
        .get();

    final notifications = querySnapshot.docs.map((doc) {
      return NotificationModel.fromFirestore(
        doc.id,
        doc.data() as Map<String, dynamic>,
      );
    }).toList();

    final unseenCount = notifications.where((n) => !n.seen).length;

    _notifications = notifications;
    _unseenCount = unseenCount;
    notifyListeners();
  }
}
