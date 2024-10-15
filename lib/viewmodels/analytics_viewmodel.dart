import 'package:flutter/foundation.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class AnalyticsViewModel extends ChangeNotifier {
  int totalOrders = 0;
  double totalSales = 0.0;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<String> dates = [];
  List<int> dailyOrders = [];
  List<double> dailySales = [];
  List<int> weeklyOrders = [];
  List<double> weeklySales = [];

  List<String> allProducts = [
    "Pear",
    "Watermelon",
    "Orange",
    "Peach",
    "Fruit Basket",
    "Fresh Fruit Medley"
  ];

  List<int> productOrderCounts = [
    15,
    30,
    25,
    10,
    5,
    20
  ]; // Dummy order counts for each product

  List<Map<String, dynamic>> popularProducts = [];

  Future<void> fetchAnalyticsData() async {
    _isLoading = true;
    notifyListeners();

    dailyOrders = List.generate(30, (index) => Random().nextInt(50));
    dailySales =
        List.generate(30, (index) => (Random().nextDouble() * 500).toDouble());

    totalOrders = dailyOrders.reduce((a, b) => a + b);
    totalSales = dailySales.reduce((a, b) => a + b);

    // Get the top 3 popular products based on order counts
    popularProducts = _getTop3PopularProducts();

    dates = List.generate(29, (index) {
      DateTime date = DateTime.now().subtract(Duration(days: index));
      return DateFormat('MM/dd').format(date);
    }).reversed.toList();

    _isLoading = false;
    notifyListeners();
  }

  List<Map<String, dynamic>> _getTop3PopularProducts() {
    List<Map<String, dynamic>> productList = [];

    for (int i = 0; i < allProducts.length; i++) {
      productList.add({
        'name': allProducts[i],
        'orders': productOrderCounts[i],
      });
    }

    // Sort products by order counts in descending order and take the top 3
    productList.sort((a, b) => b['orders'].compareTo(a['orders']));
    return productList.take(3).toList();
  }
}
