import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:unshelf_seller/core/constants/app_constants.dart';
import 'package:unshelf_seller/core/constants/firestore_constants.dart';
import 'package:unshelf_seller/core/current_user_provider.dart';
import 'package:unshelf_seller/core/interfaces/i_batch_service.dart';
import 'package:unshelf_seller/core/interfaces/i_bundle_service.dart';
import 'package:unshelf_seller/core/interfaces/i_order_service.dart';
import 'package:unshelf_seller/core/logger.dart';
import 'package:unshelf_seller/models/order_model.dart';

class OrderService implements IOrderService {
  final FirebaseFirestore _firestore;
  final CurrentUserProvider _currentUser;
  final IBatchService _batchService;
  final IBundleService _bundleService;

  OrderService({
    FirebaseFirestore? firestore,
    CurrentUserProvider? currentUser,
    required IBatchService batchService,
    required IBundleService bundleService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _currentUser = currentUser ?? CurrentUserProvider(),
        _batchService = batchService,
        _bundleService = bundleService;

  @override
  Future<OrderModel?> getOrder(String orderId) async {
    final orderDoc = await _firestore
        .collection(FirestoreConstants.orders)
        .doc(orderId)
        .get();

    if (!orderDoc.exists) {
      return null;
    }

    var order = OrderModel.fromFirestore(orderDoc);

    var buyerDoc = await _firestore
        .collection(FirestoreConstants.users)
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

  @override
  Future<List<OrderModel>> getOrders(bool forToday) async {
    final duration = forToday
        ? AppConstants.orderExpiryDuration
        : AppConstants.orderHistoryDuration;

    var orderDoc = await _firestore
        .collection(FirestoreConstants.orders)
        .where(FirestoreConstants.sellerId, isEqualTo: _currentUser.uid)
        .where(FirestoreConstants.createdAt,
            isGreaterThan: DateTime.now().subtract(duration))
        .orderBy(FirestoreConstants.createdAt, descending: false)
        .get();

    AppLogger.debug('Orders fetched: ${orderDoc.docs.length}');

    List<OrderModel> orders = orderDoc.docs
        .map((doc) => OrderModel.fromFirestore(doc))
        .toList()
        .cast<OrderModel>();

    return orders;
  }

  @override
  Future<List<OrderModel>> getOrdersWithBatchId() async {
    var orderDoc = await _firestore
        .collection(FirestoreConstants.orders)
        .where(FirestoreConstants.sellerId, isEqualTo: _currentUser.uid)
        .where(FirestoreConstants.createdAt,
            isGreaterThan:
                DateTime.now().subtract(AppConstants.orderExpiryDuration))
        .orderBy(FirestoreConstants.createdAt, descending: false)
        .get();

    AppLogger.debug('Orders containing batchId: ${orderDoc.docs.length}');

    List<OrderModel> orders = orderDoc.docs
        .map((doc) => OrderModel.fromFirestore(doc))
        .toList()
        .cast<OrderModel>();

    return orders;
  }
}
