import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unshelf_seller/models/order_model.dart';
import 'package:unshelf_seller/services/batch_service.dart';
import 'package:unshelf_seller/models/batch_model.dart';

class OrderService extends ChangeNotifier {
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

    var buyerDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(order.buyerId)
        .get();

    order.buyerName = buyerDoc['name'];

    for (var item in order.items) {
      final batchDoc = await _batchService.getBatchById(item.batchId!);
      order.products.add(batchDoc!);
    }

    return order;
  }

  Future<List<OrderModel>> getOrders() async {
    User? user = FirebaseAuth.instance.currentUser;

    final orderDocs = await FirebaseFirestore.instance
        .collection('orders')
        .where('sellerId', isEqualTo: user!.uid)
        .where('createdAt',
            isGreaterThan: DateTime.now().subtract(const Duration(days: 13)))
        .get();

    var orders =
        orderDocs.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();

    return orders;
  }

  Future<List<OrderModel>> getOrdersToday() async {
    User? user = FirebaseAuth.instance.currentUser;

    // Get the current time
    DateTime now = DateTime.now();

    // Calculate the time 24 hours ago
    DateTime twentyFourHoursAgo = now.subtract(const Duration(days: 1));

    // Fetch orders from Firestore
    final orderDocs = await FirebaseFirestore.instance
        .collection('orders')
        .where('sellerId', isEqualTo: user!.uid)
        .where('createdAt', isGreaterThan: twentyFourHoursAgo)
        .get();

    var orders =
        orderDocs.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();

    return orders;
  }
}
