import 'package:unshelf_seller/core/base_viewmodel.dart';
import 'package:unshelf_seller/core/interfaces/i_notification_service.dart';
import 'package:unshelf_seller/core/logger.dart';
import 'package:unshelf_seller/models/notification_model.dart';

class NotificationViewModel extends BaseViewModel {
  final INotificationService _notificationService;

  NotificationViewModel({required INotificationService notificationService})
      : _notificationService = notificationService;

  List<NotificationModel> _notifications = [];
  int _unseenCount = 0;

  int unseenCount() => _unseenCount;
  List<NotificationModel> get notifications => _notifications;

  Future<void> fetchNotifications() async {
    await runBusyFuture(() async {
      final notifications = await _notificationService.fetchNotifications();

      AppLogger.debug('Notifications fetched: ${notifications.length}');

      _unseenCount = notifications.where((n) => !n.seen).length;
      _notifications = notifications;
      notifyListeners();
    });
  }

  void markNotificationAsReadAsync(int index) async {
    final notificationId = _notifications[index].id;

    try {
      await _notificationService.markAsRead(notificationId);

      _notifications[index].seen = true;
      _unseenCount = _unseenCount - 1;
    } catch (e) {
      AppLogger.error('Error updating notification: $e');
    }
  }
}
