import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:unshelf_seller/core/constants/firestore_constants.dart';
import 'package:unshelf_seller/core/current_user_provider.dart';
import 'package:unshelf_seller/core/errors/app_exceptions.dart';
import 'package:unshelf_seller/core/interfaces/i_notification_service.dart';
import 'package:unshelf_seller/core/logger.dart';
import 'package:unshelf_seller/models/notification_model.dart';

class NotificationService implements INotificationService {
  final FirebaseFirestore _firestore;
  final CurrentUserProvider _currentUser;

  NotificationService({
    FirebaseFirestore? firestore,
    CurrentUserProvider? currentUser,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _currentUser = currentUser ?? CurrentUserProvider();

  @override
  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      final uid = _currentUser.uid;

      final querySnapshot = await _firestore
          .collection(FirestoreConstants.notifications)
          .where('recipient_id', isEqualTo: uid)
          .orderBy('created_at', descending: true)
          .get();

      AppLogger.debug('Notifications fetched: ${querySnapshot.docs.length}');

      return querySnapshot.docs.map((doc) {
        return NotificationModel.fromFirestore(doc.id, doc.data());
      }).toList();
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to fetch notifications', e, stackTrace);
      throw FirestoreException('Failed to fetch notifications', originalError: e);
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(FirestoreConstants.notifications)
          .doc(notificationId)
          .update({'seen': true});

      AppLogger.debug('Notification marked as read: $notificationId');
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to mark notification as read', e, stackTrace);
      throw FirestoreException('Failed to mark notification as read',
          originalError: e);
    }
  }
}
