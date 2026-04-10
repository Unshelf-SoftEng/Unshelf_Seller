import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:unshelf_seller/models/notification_model.dart';
import 'package:unshelf_seller/core/base_viewmodel.dart';
import 'package:unshelf_seller/core/logger.dart';
import 'package:unshelf_seller/core/constants/firestore_constants.dart';
import 'package:unshelf_seller/core/constants/status_constants.dart';

class DashboardViewModel extends BaseViewModel {
  DateTime today;
  int pendingOrders;
  int processedOrders;
  int completedOrders;
  int totalOrders;
  double totalSales;
  late String monthYear;
  List<NotificationModel>? _notifications;
  List<NotificationModel>? get notifications => _notifications;
  int? _unseenCount;
  int? get unseenCount => _unseenCount;

  DashboardViewModel()
      : today = DateTime.now(),
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
    setLoading(true);

    User? user = FirebaseAuth.instance.currentUser;
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final ordersSnapshot = await FirebaseFirestore.instance
          .collection(FirestoreConstants.orders)
          .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
          .where('createdAt', isLessThan: endOfDay)
          .where('sellerId', isEqualTo: user?.uid)
          .get();

      pendingOrders = ordersSnapshot.docs
          .where((doc) => doc['status'] == StatusConstants.pending)
          .length;
      processedOrders = ordersSnapshot.docs
          .where((doc) => doc['status'] == StatusConstants.ready)
          .length;
      completedOrders = ordersSnapshot.docs
          .where((doc) => doc['status'] == StatusConstants.completed)
          .length;

      // Assuming 'total' field exists in each order document for total price
      final startOfMonth = DateTime(now.year, now.month);

      totalSales = 0;

      QuerySnapshot transactionMonthly = await FirebaseFirestore.instance
          .collection(FirestoreConstants.transactions)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('sellerId', isEqualTo: user?.uid)
          .get();

      double totalEarnings = 0.0;

      for (var trans in transactionMonthly.docs) {
        if (trans['type'] == StatusConstants.sale) {
          double amount = trans['sellerEarnings'];
          totalEarnings += amount;
        }
      }

      totalSales = totalEarnings;
    } catch (e) {
      AppLogger.error('Error fetching dashboard data: $e');
    } finally {
      setLoading(false);
    }
  }

  String getCurrentMonth() {
    final now = DateTime.now();
    final dateFormat = DateFormat('MMMM yyyy');
    return dateFormat.format(now);
  }

  int _totalStockRemaining = 40;
  int get totalStockRemaining => _totalStockRemaining;
}
