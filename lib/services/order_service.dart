import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unshelf_seller/models/order_model.dart';
import 'package:unshelf_seller/services/batch_service.dart';

class OrderService extends ChangeNotifier {
  final BatchService _batchService = BatchService();

  // Future<OrderModel?> getOrder(String orderId) async {
  //   final orderDoc = await FirebaseFirestore.instance
  //       .collection('orders')
  //       .doc(orderId)
  //       .get();

  //   if (!orderDoc.exists) {
  //     return null;
  //   }

  //   var order = OrderModel.fromFirestore(orderDoc);

  //   for (var item in order.items) {
  //     final batchDoc = await _batchService.getBatchById(item.batchId!);
  //     order.products.add(batchDoc!);
  //   }

  //   return order;
  // }

  Future<List<OrderModel>> getOrders() async {
    User? user = FirebaseAuth.instance.currentUser;

    final orderDocs = await FirebaseFirestore.instance
        .collection('orders')
        .where('sellerId', isEqualTo: user!.uid)
        .where('createdAt',
            isGreaterThan: DateTime.now().subtract(Duration(days: 13)))
        .get();

    var orders =
        orderDocs.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();

    for (var order in orders) {
      for (var item in order.items) {
        final batchDoc = await _batchService.getBatchById(item.batchId!);
        order.products.add(batchDoc!);
      }

      order.buyerName = await FirebaseFirestore.instance
          .collection('users')
          .doc(order.buyerId)
          .get()
          .then((doc) => doc['name']);
    }

    return orders;
  }
}
