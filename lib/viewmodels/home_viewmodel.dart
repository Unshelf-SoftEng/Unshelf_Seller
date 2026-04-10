import 'package:unshelf_seller/core/base_viewmodel.dart';
import 'package:unshelf_seller/core/interfaces/i_notification_service.dart';
import 'package:unshelf_seller/models/notification_model.dart';

class HomeViewModel extends BaseViewModel {
  final INotificationService _notificationService;

  HomeViewModel({required INotificationService notificationService})
      : _notificationService = notificationService;

  List<NotificationModel> _notifications = [];
  int _unseenCount = 0;

  int get unseenCount => _unseenCount;
  List<NotificationModel> get notifications => _notifications;

  Future<void> fetchNotifications() async {
    await runBusyFuture(() async {
      final notifications = await _notificationService.fetchNotifications();

      final unseenCount = notifications.where((n) => !n.seen).length;

      _notifications = notifications;
      _unseenCount = unseenCount;
    });
  }
}
