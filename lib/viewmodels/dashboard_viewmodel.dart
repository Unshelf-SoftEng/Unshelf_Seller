import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:unshelf_seller/models/notification_model.dart';
import 'package:unshelf_seller/core/base_viewmodel.dart';
import 'package:unshelf_seller/core/interfaces/i_analytics_service.dart';
import 'package:unshelf_seller/core/constants/status_constants.dart';
import 'package:unshelf_seller/core/service_locator.dart';

class DashboardViewModel extends BaseViewModel {
  final IAnalyticsService _analyticsService;

  DateTime today;
  int pendingOrders;
  int processedOrders;
  int completedOrders;
  int totalOrders;
  double totalSales;
  late String monthYear;
  List<NotificationModel>? _notifications;
  List<NotificationModel>? get notifications => _notifications;
  final int? _unseenCount;
  int? get unseenCount => _unseenCount;

  DashboardViewModel({IAnalyticsService? analyticsService})
      : _analyticsService =
            analyticsService ?? locator<IAnalyticsService>(),
        today = DateTime.now(),
        pendingOrders = 0,
        processedOrders = 0,
        completedOrders = 0,
        totalOrders = 0,
        totalSales = 0.0,
        _unseenCount = 0 {
    monthYear = getCurrentMonth();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    await runBusyFuture(() async {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final endOfDay = todayStart.add(const Duration(days: 1));

      final orderDocs =
          await _analyticsService.fetchOrders(since: todayStart);

      // Filter to today only (service returns >= todayStart, trim >= endOfDay)
      final todayOrders = orderDocs.where((doc) {
        final createdAt = doc['createdAt'];
        if (createdAt == null) return true;
        final date = (createdAt as Timestamp).toDate();
        return date.isBefore(endOfDay);
      }).toList();

      pendingOrders = todayOrders
          .where((doc) => doc['status'] == StatusConstants.pending)
          .length;
      processedOrders = todayOrders
          .where((doc) => doc['status'] == StatusConstants.ready)
          .length;
      completedOrders = todayOrders
          .where((doc) => doc['status'] == StatusConstants.completed)
          .length;

      totalOrders = todayOrders.length;

      final startOfMonth = DateTime(now.year, now.month);

      final transDocs =
          await _analyticsService.fetchTransactions(since: startOfMonth);

      double totalEarnings = 0.0;
      for (var trans in transDocs) {
        if (trans['type'] == StatusConstants.sale) {
          double amount = (trans['sellerEarnings'] as num).toDouble();
          totalEarnings += amount;
        }
      }

      totalSales = totalEarnings;
    });
  }

  String getCurrentMonth() {
    final now = DateTime.now();
    final dateFormat = DateFormat('MMMM yyyy');
    return dateFormat.format(now);
  }

  final int _totalStockRemaining = 40;
  int get totalStockRemaining => _totalStockRemaining;
}
