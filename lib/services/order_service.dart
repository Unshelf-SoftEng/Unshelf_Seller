import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unshelf_seller/models/order_model.dart';
import 'package:unshelf_seller/services/batch_service.dart';
import 'package:unshelf_seller/services/bundle_service.dart';

class OrderService extends ChangeNotifier {
  final BatchService _batchService = BatchService();
  final BundleService _bundleService = BundleService();

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
      if (item.isBundle!) {
        final bundleDoc = await _bundleService.getBundle(item.batchId!);
        order.bundles!.add(bundleDoc!);
        continue;
      } else {
        final batchDoc = await _batchService.getBatchById(item.batchId!);
        order.products!.add(batchDoc!);
      }
    }

    return order;
  }

  Future<List<OrderModel>> getOrders(bool forToday) async {
    User? user = FirebaseAuth.instance.currentUser;

    var orderDoc;

    if (forToday) {
      orderDoc = await FirebaseFirestore.instance
          .collection('orders')
          .where('sellerId', isEqualTo: user!.uid)
          .where('createdAt',
              isGreaterThan: DateTime.now().subtract(const Duration(hours: 24)))
          .orderBy('createdAt', descending: false)
          .get();
    } else {
      orderDoc = await FirebaseFirestore.instance
          .collection('orders')
          .where('sellerId', isEqualTo: user!.uid)
          .where('createdAt',
              isGreaterThan: DateTime.now().subtract(const Duration(days: 17)))
          .orderBy('createdAt', descending: false)
          .get();
    }

    print('Orders today: ${orderDoc.docs.length}');

    List<OrderModel> orders = orderDoc.docs
        .map((doc) => OrderModel.fromFirestore(doc))
        .toList()
        .cast<OrderModel>();

    return orders;
  }
}
