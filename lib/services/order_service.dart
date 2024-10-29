import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unshelf_seller/models/order_model.dart';
import 'package:unshelf_seller/services/product_service.dart';
import 'package:unshelf_seller/services/batch_service.dart';

class OrderService extends ChangeNotifier {
  final ProductService _productService = ProductService();
  final BatchService _batchService = BatchService();

  Future<OrderModel?> getOrder(String orderId) async {
    final orderDoc = await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .get();

    if (!orderDoc.exists) {
      return null;
    }

    var order = OrderModel.fromFirestore(orderDoc);

    // Extract batch IDs from the order
    List<String> batchNumbers =
        order.items.map((item) => item.batchNumber).toList();

    // Loop through each item in the order to fetch batch details
    for (var item in order.items) {
      final batchDoc = await _batchService.getBatchById(item.batchNumber);
    }

    return order;
  }

  Future<List<OrderModel>> getOrders() async {
    User? user = FirebaseAuth.instance.currentUser;

    final orderDocs = await FirebaseFirestore.instance
        .collection('orders')
        .where('sellerId', isEqualTo: user!.uid)
        .get();

    // Map each document to an OrderModel instance and return the list
    var orders =
        orderDocs.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();

    return orders;
  }
}
