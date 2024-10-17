import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AnalyticsViewModel extends ChangeNotifier {
  int totalOrders = 0;
  double totalSales = 0.0;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<String> dates = [];
  Map<String, int> dailyOrdersMap = {};
  Map<String, double> dailySalesMap = {};
  List<int> weeklyOrders = [];
  List<double> weeklySales = [];

  List<Map<String, dynamic>> popularProducts = [];

  Future<void> fetchAnalyticsData() async {
    _isLoading = true;
    notifyListeners();

    // Initialize Firestore instance
    final db = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    User? user = auth.currentUser;

    if (user == null) {
      print('No user is logged in');
      return;
    }

    String userId = user.uid;
    Map<String, int> productQuantities = {};
    DateTime today = DateTime.now();
    DateTime thirtyDaysAgo = today.subtract(Duration(days: 29));

    for (int i = 0; i < 30; i++) {
      DateTime date = today.subtract(Duration(days: 29 - i));
      String formattedDate = DateFormat('MM/dd').format(date);
      dailyOrdersMap[formattedDate] = 0;
    }

    for (int i = 0; i < 30; i++) {
      DateTime date = today.subtract(Duration(days: 29 - i));
      String formattedDate = DateFormat('MM/dd').format(date);
      dailySalesMap[formattedDate] = 0.0;
    }

    try {
      QuerySnapshot orderSnapshot = await db
          .collection('orders')
          .where('sellerId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: thirtyDaysAgo)
          .get();

      QuerySnapshot transactionSnapshot = await db
          .collection('transactions')
          .where('sellerId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: thirtyDaysAgo)
          .get();

      // Process each order for product quantities
      for (var orderDoc in orderSnapshot.docs) {
        DateTime orderDate = (orderDoc['createdAt'] as Timestamp).toDate();
        String formattedDate = DateFormat('MM/dd').format(orderDate);

        dailyOrdersMap[formattedDate] = dailyOrdersMap[formattedDate]! + 1;
        totalOrders += 1;

        List<dynamic> orderItems = orderDoc['orderItems'];
        for (var item in orderItems) {
          String productId = item['productId'];
          int quantity = item['quantity'];

          if (productQuantities.containsKey(productId)) {
            productQuantities[productId] =
                productQuantities[productId]! + quantity;
          } else {
            productQuantities[productId] = quantity;
          }
        }
      }

      for (var transactionDoc in transactionSnapshot.docs) {
        DateTime transactionDate =
            (transactionDoc['date'] as Timestamp).toDate();
        double sellerEarnings = transactionDoc['sellerEarnings'].toDouble();

        String formattedDate = DateFormat('MM/dd').format(transactionDate);
        // Check if the key exists
        if (dailySalesMap.containsKey(formattedDate)) {
          // If it exists, add sellerEarnings to the current value
          dailySalesMap[formattedDate] =
              dailySalesMap[formattedDate]! + sellerEarnings;
        }

        totalSales += sellerEarnings;
      }

      // Get the top 3 popular products based on quantity ordered
      List<Map<String, dynamic>> popularProducts = [];
      List<MapEntry<String, int>> sortedProducts = productQuantities.entries
          .toList()
        ..sort((a, b) =>
            b.value.compareTo(a.value)); // Sort by quantity in descending order

      for (var entry in sortedProducts.take(3)) {
        // Fetch product details (like name) from Firestore using productId
        DocumentSnapshot productDoc =
            await db.collection('products').doc(entry.key).get();
        String productName = productDoc['name'];

        popularProducts.add({
          'productId': entry.key,
          'productName': productName,
          'quantityOrdered': entry.value,
        });
      }
    } catch (e) {
      print("Error fetching analytics data: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
