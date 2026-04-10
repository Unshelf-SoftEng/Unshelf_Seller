import 'package:unshelf_seller/models/notification_model.dart';

abstract class INotificationService {
  Future<List<NotificationModel>> fetchNotifications();
  Future<void> markAsRead(String notificationId);
}
