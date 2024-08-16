import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardViewModel extends ChangeNotifier {
  // Example data for the day
  DateTime today;
  int pendingOrders;
  int processedOrders;
  int completedOrders;
  int totalOrders;
  double totalSales;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DashboardViewModel()
      : today = DateTime.now(),
        pendingOrders = 0,
        processedOrders = 0,
        completedOrders = 0,
        totalOrders = 0,
        totalSales = 0.0 {
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
          .where('created_at', isGreaterThanOrEqualTo: startOfDay)
          .where('created_at', isLessThan: endOfDay)
          .where('seller_id', isEqualTo: user?.uid)
          .get();

      pendingOrders =
          ordersSnapshot.docs.where((doc) => doc['status'] == 'Pending').length;
      processedOrders =
          ordersSnapshot.docs.where((doc) => doc['status'] == 'Ready').length;
      completedOrders = ordersSnapshot.docs
          .where((doc) => doc['status'] == 'Completed')
          .length;

      print('Pending orders: $pendingOrders');
      print('Processed orders: $processedOrders');
      print('Completed orders: $completedOrders');

      // // Assuming 'total' field exists in each order document for total price
      final startOfMonth = DateTime(now.year, now.month);
      final endOfMonth =
          DateTime(now.year, now.month + 1); // Start of next month

      var ordersMonthly = await FirebaseFirestore.instance
          .collection('orders')
          .where('created_at', isGreaterThanOrEqualTo: startOfMonth)
          .where('created_at', isLessThan: endOfMonth)
          .where('seller_id', isEqualTo: user?.uid)
          .get();

      totalSales = 0;

      for (var orderDoc
          in ordersMonthly.docs.where((doc) => doc['status'] == 'Completed')) {
        final orderItems = orderDoc['order_items'] as List<dynamic>;

        for (var item in orderItems) {
          final productId = item['product_id'] as String;
          final quantity = (item['quantity'] as num).toDouble();
          final productDoc = await FirebaseFirestore.instance
              .collection('products')
              .doc(productId)
              .get();

          final productPrice = (productDoc['price'] as num).toDouble();
          totalSales += productPrice * quantity;
        }
      }
      print('Total sales: $totalSales');

      totalOrders = ordersMonthly.docs.length;

      print('Total orders: $totalOrders');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Handle errors appropriately, e.g., log them or show a user-friendly message
      print('Error fetching dashboard data: $e');
    }
  }
}
