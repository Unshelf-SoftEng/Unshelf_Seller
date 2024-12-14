import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnalyticsViewModel extends ChangeNotifier {
  int totalOrders = 0;
  double totalSales = 0.0;
  int totalCompletedOrders = 0;
  int totalReadyOrders = 0;
  int totalPendingOrders = 0;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<DateTime, int> _dailyOrdersMap = {};
  Map<DateTime, int> get dailyOrdersMap => _dailyOrdersMap;
  Map<DateTime, int> _weeklyOrdersMap = {};
  Map<DateTime, int> get weeklyOrdersMap => _weeklyOrdersMap;
  Map<DateTime, int> _monthlyOrdersMap = {};
  Map<DateTime, int> get monthlyOrdersMap => _monthlyOrdersMap;
  Map<DateTime, int> _annualOrdersMap = {};
  Map<DateTime, int> get annualOrdersMap => _annualOrdersMap;

  double _dailyMaxYOrder = 0.0;
  double get dailyMaxYOrder => _dailyMaxYOrder;
  double _weeklyMaxYOrder = 0.0;
  double get weeklyMaxYOrder => _weeklyMaxYOrder;
  double _monthlyMaxYOrder = 0.0;
  double get monthlyMaxYOrder => _monthlyMaxYOrder;
  double _annualMaxYOrder = 0.0;
  double get annualMaxYOrder => _annualMaxYOrder;

  Map<DateTime, double> _dailySalesMap = {};
  Map<DateTime, double> get dailySalesMap => _dailySalesMap;
  Map<DateTime, double> _weeklySalesMap = {};
  Map<DateTime, double> get weeklySalesMap => _weeklySalesMap;
  Map<DateTime, double> _monthlySalesMap = {};
  Map<DateTime, double> get monthlySalesMap => _monthlySalesMap;
  Map<DateTime, double> _annualSalesMap = {};
  Map<DateTime, double> get annualSalesMap => _annualSalesMap;

  double _dailyMaxYSales = 0.0;
  double get dailyMaxYSales => _dailyMaxYSales;
  double _weeklyMaxYSales = 0.0;
  double get weeklyMaxYSales => _weeklyMaxYSales;
  double _monthlyMaxYSales = 0.0;
  double get monthlyMaxYSales => _monthlyMaxYSales;
  double _annualMaxYSales = 0.0;
  double get annualMaxYSales => _annualMaxYSales;

  List<Map<String, dynamic>> topProducts = [];

  User? user = FirebaseAuth.instance.currentUser;

  Future<void> fetchAnalyticsData() async {
    _isLoading = true;
    notifyListeners();
    await getTotals();
    await getOrdersandSalesData();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getOrdersandSalesData() async {
    await getOrdersMap('Daily');
    await getOrdersMap('Weekly');
    await getOrdersMap('Monthly');
    await getOrdersMap('Annual');

    await getSalesMap('Daily');
    await getSalesMap('Weekly');
    await getSalesMap('Monthly');
    await getSalesMap('Annual');

    print('Weekly Orders: $_weeklyOrdersMap');
    print('Weekly Sales: $_weeklySalesMap');
  }

  Future<void> getTotals() async {
    _isLoading = true;
    notifyListeners();
    try {
      totalOrders = 0;
      totalSales = 0.0;
      totalCompletedOrders = 0;
      totalReadyOrders = 0;
      totalPendingOrders = 0;

      // Fetch orders
      final QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('sellerId', isEqualTo: user!.uid)
          .get();

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

      QuerySnapshot transactionSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('sellerId', isEqualTo: user!.uid)
          .get();

      for (var transDoc in transactionSnapshot.docs) {
        if (transDoc['type'] == 'Sale') {
          double transAmount = (transDoc['sellerEarnings'] ?? 0).toDouble();
          totalSales += transAmount;
        }
      }
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

    DateTime today = DateTime.now();
    _initializeOrdersMap(period, today);

    try {
      final db = FirebaseFirestore.instance;

      QuerySnapshot orderSnapshot = await db
          .collection('orders')
          .where('sellerId', isEqualTo: user!.uid)
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

    _calculateMaxYOrder(period);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getSalesMap(String period) async {
    _isLoading = true;
    notifyListeners();

    DateTime today = DateTime.now();
    _initializeSalesMap(period, today);

    try {
      final db = FirebaseFirestore.instance;

      QuerySnapshot transactionSnapshot = await db
          .collection('transactions')
          .where('sellerId', isEqualTo: user!.uid)
          .where('date', isGreaterThanOrEqualTo: _getStartDate(period, today))
          .get();

      for (var transDoc in transactionSnapshot.docs) {
        if (transDoc['type'] == 'Sale') {
          DateTime transDate = (transDoc['date'] as Timestamp).toDate();
          double transAmount = (transDoc['sellerEarnings'] ?? 0).toDouble();
          _updateSalesMap(period, transDate, transAmount);
        }
      }
    } catch (e) {
      print("Error fetching sales data: $e");
    }

    _calculateMaxYSales(period);

    _isLoading = false;
    notifyListeners();
  }

  void _initializeOrdersMap(String period, DateTime today) {
    switch (period) {
      case 'Daily':
        for (int i = 0; i < 14; i++) {
          DateTime date = today.subtract(Duration(days: 14 - i));
          DateTime saveDate = DateTime(date.year, date.month, date.day);
          _dailyOrdersMap[saveDate] = 0;
        }
        break;
      case 'Weekly':
        DateTime lastMonday = today.subtract(Duration(days: today.weekday - 1));
        for (int i = 0; i < 4; i++) {
          DateTime weekStartDate =
              lastMonday.subtract(Duration(days: 21 - (i * 7)));

          weekStartDate = DateTime(
              weekStartDate.year, weekStartDate.month, weekStartDate.day);

          _weeklyOrdersMap[weekStartDate] = 0;
        }
        break;
      case 'Monthly':
        for (int i = 5; i >= 0; i--) {
          int year = today.year;
          int month = today.month - i;

          if (month <= 0) {
            month += 12;
            year--;
          }

          DateTime monthDate = DateTime(year, month, 1);
          _monthlyOrdersMap[monthDate] = 0;
        }
        break;
      case 'Annual':
        for (int i = 2; i >= 0; i--) {
          DateTime yearDate = DateTime(today.year - i, 1, 1);
          _annualOrdersMap[yearDate] = 0;
        }
        break;

      default:
        print('Invalid time period');
        break;
    }
  }

  void _initializeSalesMap(String period, DateTime today) {
    switch (period) {
      case 'Daily':
        for (int i = 0; i < 14; i++) {
          DateTime date = today.subtract(Duration(days: 14 - i));
          DateTime saveDate = DateTime(date.year, date.month, date.day);
          _dailySalesMap[saveDate] = 0.0;
        }
        break;
      case 'Weekly':
        DateTime lastMonday = today.subtract(Duration(days: today.weekday - 1));
        for (int i = 0; i < 4; i++) {
          DateTime weekStartDate =
              lastMonday.subtract(Duration(days: 21 - (i * 7)));

          weekStartDate = DateTime(
              weekStartDate.year, weekStartDate.month, weekStartDate.day);
          _weeklySalesMap[weekStartDate] = 0;
        }
        break;
      case 'Monthly':
        for (int i = 5; i >= 0; i--) {
          int year = today.year;
          int month = today.month - i;

          if (month <= 0) {
            month += 12;
            year--;
          }

          DateTime monthDate = DateTime(year, month, 1);
          _monthlySalesMap[monthDate] = 0.0;
        }
        break;
      case 'Annual':
        for (int i = 2; i >= 0; i--) {
          // Start from the oldest year and move forward
          DateTime yearDate = DateTime(today.year - i, 1, 1);
          _annualSalesMap[yearDate] = 0.0; // Initialize sales as 0.0
        }
        break;
      default:
        break;
    }
  }

  void _updateOrdersMap(String period, DateTime orderDate) {
    DateTime key;

    switch (period) {
      case 'Daily':
        key = DateTime(orderDate.year, orderDate.month, orderDate.day);

        if (_dailyOrdersMap.containsKey(key)) {
          _dailyOrdersMap[key] = (_dailyOrdersMap[key] ?? 0) + 1;
        }

        break;
      case 'Weekly':
        key = DateTime(
          orderDate.year,
          orderDate.month,
          orderDate.day,
        ).subtract(Duration(days: orderDate.weekday - 1));

        key = DateTime(key.year, key.month, key.day);

        _weeklyOrdersMap[key] = (_weeklyOrdersMap[key] ?? 0) + 1;

        break;
      case 'Monthly':
        key = DateTime(orderDate.year, orderDate.month, 1);

        if (_monthlyOrdersMap.containsKey(key)) {
          _monthlyOrdersMap[key] = (_monthlyOrdersMap[key] ?? 0) + 1;
        }

        break;
      case 'Annual':
        key = DateTime(orderDate.year, 1, 1);

        if (_annualOrdersMap.containsKey(key)) {
          _annualOrdersMap[key] = (_annualOrdersMap[key] ?? 0) + 1;
        }

        break;
      default:
        return;
    }
  }

  void _updateSalesMap(String period, DateTime saleDate, double saleAmount) {
    DateTime key;

    switch (period) {
      case 'Daily':
        key = DateTime(saleDate.year, saleDate.month, saleDate.day);

        if (_dailySalesMap.containsKey(key)) {
          _dailySalesMap[key] = (_dailySalesMap[key] ?? 0.0) + saleAmount;
        }

        break;
      case 'Weekly':
        key = DateTime(
          saleDate.year,
          saleDate.month,
          saleDate.day,
        ).subtract(Duration(days: saleDate.weekday - 1));

        key = DateTime(key.year, key.month, key.day);

        _weeklySalesMap[key] = (_weeklySalesMap[key] ?? 0.0) + saleAmount;

        break;
      case 'Monthly':
        key = DateTime(saleDate.year, saleDate.month, 1);

        if (_monthlySalesMap.containsKey(key)) {
          _monthlySalesMap[key] = (_monthlySalesMap[key] ?? 0.0) + saleAmount;
        }

        break;
      case 'Annual':
        key = DateTime(saleDate.year, 1, 1);

        if (_annualSalesMap.containsKey(key)) {
          _annualSalesMap[key] = (_annualSalesMap[key] ?? 0.0) + saleAmount;
        }

        break;
      default:
        return;
    }
  }

  void _calculateMaxYOrder(String period) {
    switch (period) {
      case 'Daily':
        if (_dailyOrdersMap.isEmpty) {
          _dailyMaxYOrder = 0.0;
        } else {
          int maxOrderCount =
              _dailyOrdersMap.values.reduce((a, b) => a > b ? a : b);
          _dailyMaxYOrder = maxOrderCount.toDouble();
        }
        break;

      case 'Weekly':
        if (_weeklyOrdersMap.isEmpty) {
          _weeklyMaxYOrder = 0.0;
        } else {
          int maxOrderCount =
              _weeklyOrdersMap.values.reduce((a, b) => a > b ? a : b);
          _weeklyMaxYOrder = maxOrderCount.toDouble();
        }
        break;

      case 'Monthly':
        if (_monthlyOrdersMap.isEmpty) {
          _monthlyMaxYOrder = 0.0;
        } else {
          int maxOrderCount =
              _monthlyOrdersMap.values.reduce((a, b) => a > b ? a : b);
          _monthlyMaxYOrder = maxOrderCount.toDouble();
        }
        break;

      case 'Annual':
        if (_annualOrdersMap.isEmpty) {
          _annualMaxYOrder = 0.0;
        } else {
          int maxOrderCount =
              _annualOrdersMap.values.reduce((a, b) => a > b ? a : b);
          _annualMaxYOrder = maxOrderCount.toDouble();
        }
        break;
    }
  }

  void _calculateMaxYSales(String period) {
    switch (period) {
      case 'Daily':
        if (_dailySalesMap.isEmpty) {
          _dailyMaxYSales = 0.0;
        } else {
          double maxSalesAmount =
              _dailySalesMap.values.reduce((a, b) => a > b ? a : b);
          _dailyMaxYSales = maxSalesAmount.ceil().toDouble();
        }
        break;
      case 'Weekly':
        if (_weeklySalesMap.isEmpty) {
          _weeklyMaxYSales = 0.0;
        } else {
          double maxSalesAmount =
              _weeklySalesMap.values.reduce((a, b) => a > b ? a : b);
          _weeklyMaxYSales = maxSalesAmount.ceil().toDouble();
        }
        break;
      case 'Monthly':
        if (_monthlySalesMap.isEmpty) {
          _monthlyMaxYSales = 0.0;
        } else {
          double maxSalesAmount =
              _monthlySalesMap.values.reduce((a, b) => a > b ? a : b);
          _monthlyMaxYSales = maxSalesAmount.ceil().toDouble();
        }
        break;
      case 'Annual':
        if (_annualSalesMap.isEmpty) {
          _annualMaxYSales = 0.0;
        } else {
          double maxSalesAmount =
              _annualSalesMap.values.reduce((a, b) => a > b ? a : b);
          _annualMaxYSales = maxSalesAmount.ceil().toDouble();
        }
        break;
    }
  }

  DateTime _getStartDate(String period, DateTime today) {
    switch (period) {
      case 'Daily':
        return today.subtract(Duration(days: 15));
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
