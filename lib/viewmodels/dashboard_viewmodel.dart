import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DashboardViewModel extends ChangeNotifier {
  DateTime today;
  int pendingOrders;
  int processedOrders;
  int completedOrders;
  int totalOrders;
  double totalSales;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  late String monthYear;

  DashboardViewModel()
      : today = DateTime.now(),
        pendingOrders = 0,
        processedOrders = 0,
        completedOrders = 0,
        totalOrders = 0,
        totalSales = 0.0 {
    monthYear = getCurrentMonth();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    notifyListeners();

    User? user = FirebaseAuth.instance.currentUser;
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
          .where('createdAt', isLessThan: endOfDay)
          .where('sellerId', isEqualTo: user?.uid)
          .get();

      pendingOrders =
          ordersSnapshot.docs.where((doc) => doc['status'] == 'Pending').length;
      processedOrders =
          ordersSnapshot.docs.where((doc) => doc['status'] == 'Ready').length;
      completedOrders = ordersSnapshot.docs
          .where((doc) => doc['status'] == 'Completed')
          .length;

      // // Assuming 'total' field exists in each order document for total price
      // final startOfMonth = DateTime(now.year, now.month);

      // QuerySnapshot ordersMonthly = await FirebaseFirestore.instance
      //     .collection('orders')
      //     .where('createdAt', isGreaterThanOrEqualTo: startOfMonth)
      //     .where('sellerId', isEqualTo: user?.uid)
      //     .get();

      // totalSales = 0;

      // QuerySnapshot transactionMonthly = await FirebaseFirestore.instance
      //     .collection('transactions')
      //     .where('date', isGreaterThanOrEqualTo: startOfMonth)
      //     .where('sellerId', isEqualTo: user?.uid)
      //     .get();

      // double totalEarnings = 0.0;

      // for (var trans in transactionMonthly.docs) {
      //   if (trans['type'] == 'Sale') {
      //     double amount = trans['sellerEarnings'];
      //     totalEarnings += amount;
      //   }
      // }

      // totalSales = totalEarnings;
      // totalOrders = ordersMonthly.docs.length;
    } catch (e) {
      print('Error fetching dashboard data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String getCurrentMonth() {
    final now = DateTime.now();
    final dateFormat = DateFormat('MMMM yyyy');
    return dateFormat.format(now);
  }
}
