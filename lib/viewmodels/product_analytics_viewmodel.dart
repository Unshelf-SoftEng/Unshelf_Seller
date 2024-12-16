import 'package:flutter/material.dart';
import 'package:unshelf_seller/services/product_service.dart';
import 'package:unshelf_seller/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductAnalyticsViewModel extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;

  List<Map<String, dynamic>> topProducts = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  User? user = FirebaseAuth.instance.currentUser;

  Future<void> fetchProductAnalytics() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 10));
    // Fetch products from the service
    _products = await _productService.getProducts();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getTopProducts() async {
    _isLoading = true;
    notifyListeners();
    // Clear any existing data
    topProducts.clear();

    // Fetch all orders
    final QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('sellerId', isEqualTo: user!.uid)
        .where('status', isEqualTo: 'Completed')
        .where('createdAt',
            isGreaterThanOrEqualTo: DateTime.now().subtract(Duration(days: 13)))
        .get();

    Map<String, int> batchCountMap = {};
    Map<String, int> bundleCountMap = {};

    for (var orderDoc in ordersSnapshot.docs) {
      var orderItems = orderDoc['orderItems'];
      print(orderItems);

      for (var item in orderItems) {
        String batchId = item['batchId'];
        String bundleId = item['bundleId'];
        int quantity = item['quantity'];

        if (batchId != null) {
          batchCountMap[batchId] = (batchCountMap[batchId] ?? 0) + quantity;
        }
        if (bundleId != null) {
          bundleCountMap[bundleId] = (bundleCountMap[bundleId] ?? 0) + quantity;
        }
      }
    }

    Map<String, int> productEntries = {};

    batchCountMap.forEach((key, value) async {
      // Fetch batch details using the key
      DocumentSnapshot batchDoc = await FirebaseFirestore.instance
          .collection('batches')
          .doc(key) // Use 'key' to fetch the document
          .get();

      if (batchDoc.exists) {
        String productId = batchDoc['productId'];
        productEntries[productId] = (productEntries[productId] ?? 0) + value;
      }
    });

    var sortedEntries = productEntries.entries.toList()
      ..sort((a, b) =>
          b.value.compareTo(a.value)); // Sort by value in descending order

    var top5 = sortedEntries.take(5).toList();

    for (var entry in top5) {
      // Fetch product details using the productId
      DocumentSnapshot productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(entry.key) // Use 'key' to fetch the document
          .get();

      if (productDoc.exists) {
        topProducts.add({
          'productId': productDoc.id,
          'name': productDoc['name'],
          'quantity': entry.value,
        });
      }
    }

    _isLoading = false;
    notifyListeners();
  }
}
