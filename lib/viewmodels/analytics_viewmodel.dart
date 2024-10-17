import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AnalyticsViewModel extends ChangeNotifier {
  int totalOrders = 0;
  double totalSales = 0.0;
  int totalCompletedOrders = 0;
  int totalReadyOrders = 0;
  int totalPendingOrders = 0;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Map<DateTime, int> _ordersMap = {};
  Map<DateTime, double> _salesMap = {};
  double _maxXOrder = 0;
  double _maxYOrder = 0;
  double _maxXSales = 0;
  double _maxYSales = 0;

  // Getter for orders map
  Map<DateTime, int> get ordersMap => _ordersMap;

  // Getter for sales map
  Map<DateTime, double> get salesMap => _salesMap;

  // Max X value for orders
  double get maxXOrder => _maxXOrder;
  double get maxYOrder => _maxYOrder;
  double get maxXSales => _maxXSales;
  double get maxYSales => _maxYSales;

  List<Map<String, dynamic>> topProducts = [];

  Future<void> fetchAnalyticsData() async {
    _isLoading = true;
    notifyListeners();

    await getTotals();
    await getOrdersMap('Daily');
    await getSalesMap('Daily');
    await getTopProducts();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getTopProducts() async {
    _isLoading = true;
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }
    // Clear any existing data
    topProducts.clear();

    // Fetch all orders
    final QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('sellerId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'Completed')
        .get();
    // Map to hold product quantities
    Map<String, int> productCountMap = {};

    // Iterate through orders
    for (var orderDoc in ordersSnapshot.docs) {
      List<dynamic> orderItems = orderDoc['orderItems'];
      for (var item in orderItems) {
        String productId = item['productId'];
        int quantity = item['quantity'];

        // Increment product count
        if (productCountMap.containsKey(productId)) {
          productCountMap[productId] = productCountMap[productId]! + quantity;
        } else {
          productCountMap[productId] = quantity;
        }
      }
    }

    // Convert the map to a list of products and their quantities
    List<MapEntry<String, int>> productEntries =
        productCountMap.entries.toList();

    // Sort products by quantity in descending order
    productEntries.sort((a, b) => b.value.compareTo(a.value));

    // Get top 5 products
    for (int i = 0; i < productEntries.length && i < 5; i++) {
      String productId = productEntries[i].key;
      int totalQuantity = productEntries[i].value;

      // Fetch product details
      DocumentSnapshot productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (productDoc.exists) {
        topProducts.add({
          'productId': productId,
          'name': productDoc['name'],
          'imageUrl': productDoc['mainImageUrl'],
          'totalQuantity': totalQuantity,
        });
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getTotals() async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      // Reset totals before fetching
      totalOrders = 0;
      totalSales = 0.0;
      totalCompletedOrders = 0;
      totalReadyOrders = 0;
      totalPendingOrders = 0;

      // Fetch orders
      final QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('sellerId', isEqualTo: user.uid) // Filter by seller
          .get();

      // Loop through all orders
      for (var doc in ordersSnapshot.docs) {
        totalOrders++; // Increment total orders

        String status = (doc.data() as Map<String, dynamic>)['status'];
        if (status == 'Completed') {
          totalCompletedOrders++;
        } else if (status == 'Ready') {
          totalReadyOrders++;
        } else if (status == 'Pending') {
          totalPendingOrders++;
        }
      }

      // Fetch transactions
      QuerySnapshot transactionSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('sellerId', isEqualTo: user.uid)
          .get();

      // Loop through transactions to calculate total sales
      for (var transDoc in transactionSnapshot.docs) {
        double transAmount = (transDoc['sellerEarnings'] ?? 0.0);
        totalSales += transAmount; // Accumulate total sales
      }

      // Log totals for debugging
      print('Total Orders: $totalOrders');
      print('Total Sales: ₱${totalSales.toStringAsFixed(2)}');
      print('Total Completed Orders: $totalCompletedOrders');
      print('Total Ready Orders: $totalReadyOrders');
      print('Total Pending Orders: $totalPendingOrders');
    } catch (e) {
      // Handle errors
      print('Error fetching totals: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getOrdersMap(String period) async {
    _isLoading = true;
    notifyListeners();

    _ordersMap.clear();

    DateTime today = DateTime.now();
    _initializeOrdersMap(period, today);

    try {
      final db = FirebaseFirestore.instance;
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      QuerySnapshot orderSnapshot = await db
          .collection('orders')
          .where('sellerId', isEqualTo: user.uid)
          .where('createdAt',
              isGreaterThanOrEqualTo: _getStartDate(period, today))
          .get();

      for (var orderDoc in orderSnapshot.docs) {
        DateTime orderDate = (orderDoc['createdAt'] as Timestamp).toDate();
        _updateOrdersMap(period, orderDate);
      }
    } catch (e) {
      print("Error fetching orders data: $e");
    }

    _calculateMaxYOrder();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getSalesMap(String period) async {
    _isLoading = true;
    notifyListeners();

    _salesMap.clear();

    DateTime today = DateTime.now();
    _initializeSalesMap(period, today);

    try {
      final db = FirebaseFirestore.instance;
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      QuerySnapshot transactionSnapshot = await db
          .collection('transactions')
          .where('sellerId', isEqualTo: user.uid)
          .where('date', isGreaterThanOrEqualTo: _getStartDate(period, today))
          .get();

      for (var transDoc in transactionSnapshot.docs) {
        DateTime transDate = (transDoc['date'] as Timestamp).toDate();
        double transAmount =
            transDoc['sellerEarnings'] ?? 0.0; // Assuming 'amount' field exists
        _updateSalesMap(period, transDate, transAmount);
      }
    } catch (e) {
      print("Error fetching sales data: $e");
    }

    _calculateMaxYSales();

    _isLoading = false;
    notifyListeners();
  }

  void _initializeOrdersMap(String period, DateTime today) {
    switch (period) {
      case 'Daily':
        for (int i = 0; i < 30; i++) {
          DateTime date = today.subtract(Duration(days: 29 - i));
          DateTime saveDate = DateTime(date.year, date.month, date.day);
          _ordersMap[saveDate] = 0;
        }
        _maxXOrder = 30;
        break;
      case 'Weekly':
        DateTime lastMonday = today.subtract(Duration(days: today.weekday - 1));
        for (int i = 0; i < 4; i++) {
          DateTime weekStartDate =
              lastMonday.subtract(Duration(days: 21 - (i * 7)));
          _ordersMap[weekStartDate] = 0;
        }
        _maxXOrder = 4;
        break;
      case 'Monthly':
        for (int i = 11; i >= 0; i--) {
          int year = today.year;
          int month = today.month - i;

          if (month <= 0) {
            month += 12;
            year--;
          }

          DateTime monthDate = DateTime(year, month, 1);
          _ordersMap[monthDate] = 0;
        }
        _maxXOrder = 12;
        break;
      case 'Annual':
        for (int i = 2; i >= 0; i--) {
          DateTime yearDate = DateTime(today.year - i, 1, 1);
          _ordersMap[yearDate] = 0;
        }
        _maxXOrder = 3;
        break;

      default:
        print('Invalid time period');
        break;
    }
  }

  void _initializeSalesMap(String period, DateTime today) {
    switch (period) {
      case 'Daily':
        for (int i = 0; i < 30; i++) {
          DateTime date = today.subtract(Duration(days: 29 - i));
          DateTime saveDate = DateTime(date.year, date.month, date.day);
          _salesMap[saveDate] = 0.0;
        }
        _maxXSales = 30;
        break;
      case 'Weekly':
        DateTime lastMonday = today.subtract(Duration(days: today.weekday - 1));
        for (int i = 0; i < 4; i++) {
          DateTime weekStartDate =
              lastMonday.subtract(Duration(days: 21 - (i * 7)));
          _ordersMap[weekStartDate] = 0;
        }
        _maxXSales = 4;
        break;
      case 'Monthly':
        for (int i = 11; i >= 0; i--) {
          int year = today.year;
          int month = today.month - i;

          // Adjust the year if the month goes below 1 (for previous year months)
          if (month <= 0) {
            month += 12;
            year--;
          }

          DateTime monthDate = DateTime(year, month, 1);
          _salesMap[monthDate] = 0.0;
        }
        _maxXSales = 12;
        break;
      case 'Annual':
        for (int i = 2; i >= 0; i--) {
          // Start from the oldest year and move forward
          DateTime yearDate = DateTime(today.year - i, 1, 1);
          _salesMap[yearDate] = 0.0; // Initialize sales as 0.0
        }
        _maxXSales = 3;
        break;

      default:
        print('Invalid time period');
        break;
    }
  }

  void _updateOrdersMap(String period, DateTime orderDate) {
    DateTime key;

    switch (period) {
      case 'Daily':
        key = DateTime(orderDate.year, orderDate.month, orderDate.day);
        break;
      case 'Weekly':
        key = orderDate.subtract(Duration(days: orderDate.weekday - 1));
        break;
      case 'Monthly':
        key = DateTime(orderDate.year, orderDate.month, 1);
        break;
      case 'Annual':
        key = DateTime(orderDate.year, 1, 1);
        break;
      default:
        return; // Skip if invalid period
    }
    if (_ordersMap.containsKey(key)) {
      print('updating orders for a certain day');
      _ordersMap[key] = (_ordersMap[key] ?? 0) + 1;
    }
  }

  void _updateSalesMap(String period, DateTime saleDate, double saleAmount) {
    DateTime key;

    switch (period) {
      case 'Daily':
        key = DateTime(saleDate.year, saleDate.month, saleDate.day);
        break;
      case 'Weekly':
        key = saleDate.subtract(Duration(days: saleDate.weekday - 1));
        break;
      case 'Monthly':
        key = DateTime(saleDate.year, saleDate.month, 1);
        break;
      case 'Annual':
        key = DateTime(saleDate.year, 1, 1);
        break;
      default:
        return;
    }

    if (_salesMap.containsKey(key)) {
      _salesMap[key] = (_salesMap[key] ?? 0.0) + saleAmount;
    }
  }

  void _calculateMaxYOrder() {
    if (_ordersMap.isEmpty) {
      _maxYOrder = -1.0;
    } else {
      int maxOrderCount = _ordersMap.values.reduce((a, b) => a > b ? a : b);
      _maxYOrder = maxOrderCount.toDouble();
    }
  }

  void _calculateMaxYSales() {
    if (_salesMap.isEmpty) {
      _maxYSales = -1.0;
    } else {
      double maxSalesAmount = _salesMap.values.reduce((a, b) => a > b ? a : b);
      _maxYSales = maxSalesAmount.ceil() as double;
    }
  }

  DateTime _getStartDate(String period, DateTime today) {
    switch (period) {
      case 'Daily':
        return today.subtract(Duration(days: 30));
      case 'Weekly':
        DateTime lastMonday = today.subtract(Duration(days: today.weekday - 1));
        return lastMonday.subtract(Duration(days: 21));
      case 'Monthly':
        return DateTime(today.year, today.month - 11, 1);
      case 'Annual':
        return DateTime(today.year - 2, 1, 1);
      default:
        throw Exception('Invalid period');
    }
  }
}
