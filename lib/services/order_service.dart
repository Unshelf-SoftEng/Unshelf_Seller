import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:unshelf_seller/core/constants/app_constants.dart';
import 'package:unshelf_seller/core/constants/firestore_constants.dart';
import 'package:unshelf_seller/core/constants/status_constants.dart';
import 'package:unshelf_seller/core/current_user_provider.dart';
import 'package:unshelf_seller/core/errors/app_exceptions.dart';
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
    try {
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
          if (bundleDoc != null) {
            order.bundles!.add(bundleDoc);
          }
          continue;
        } else {
          final batchDoc = await _batchService.getBatchById(item.batchId!);
          if (batchDoc != null) {
            order.products!.add(batchDoc);
          }
        }
      }

      return order;
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to fetch order', e, stackTrace);
      throw FirestoreException('Failed to fetch order', originalError: e);
    }
  }

  @override
  Future<List<OrderModel>> getOrders(bool forToday) async {
    try {
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
          .toList();

      return orders;
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to fetch orders', e, stackTrace);
      throw FirestoreException('Failed to fetch orders', originalError: e);
    }
  }

  @override
  Future<List<OrderModel>> getOrdersWithBatchId() async {
    try {
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
          .toList();

      return orders;
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to fetch orders with batch ID', e, stackTrace);
      throw FirestoreException('Failed to fetch orders with batch ID',
          originalError: e);
    }
  }

  @override
  Future<void> approveOrder(String orderId) async {
    try {
      final orderRef = _firestore
          .collection(FirestoreConstants.orders)
          .doc(orderId);

      await _firestore.runTransaction((transaction) async {
        transaction.update(orderRef, {
          FirestoreConstants.status: StatusConstants.processing,
        });
      });

      AppLogger.debug('Order $orderId approved (status -> processing).');
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to approve order', e, stackTrace);
      throw FirestoreException('Failed to approve order', originalError: e);
    }
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    try {
      final now = Timestamp.now();
      final orderRef = _firestore
          .collection(FirestoreConstants.orders)
          .doc(orderId);

      await _firestore.runTransaction((transaction) async {
        transaction.update(orderRef, {
          FirestoreConstants.status: StatusConstants.cancelled,
          'cancelledAt': now,
        });
      });

      AppLogger.debug('Order $orderId cancelled.');
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to cancel order', e, stackTrace);
      throw FirestoreException('Failed to cancel order', originalError: e);
    }
  }

  @override
  Future<void> fulfillOrder(
      String orderId, List<OrderItem> items, String pickupCode) async {
    try {
      for (var item in items) {
        await _firestore.runTransaction((transaction) async {
          if (item.isBundle!) {
            AppLogger.debug('Processing bundle item: ${item.batchId}');
            final bundleRef = _firestore
                .collection(FirestoreConstants.bundles)
                .doc(item.batchId);

            final bundleSnapshot = await transaction.get(bundleRef);

            if (!bundleSnapshot.exists) {
              AppLogger.error('Bundle ${item.batchId} does not exist.');
              throw Exception('Bundle ${item.batchId} does not exist.');
            }

            double currentStock =
                bundleSnapshot['stock']?.toDouble() ?? 0.0;
            double newStockValue = currentStock - item.quantity;

            if (newStockValue < 0) {
              AppLogger.error(
                  'Insufficient stock for bundle ${item.batchId}.');
              throw Exception(
                  'Insufficient stock for bundle ${item.batchId}. Cannot fulfill order.');
            }

            transaction.update(bundleRef, {
              FirestoreConstants.stock: newStockValue,
              FirestoreConstants.isListed: newStockValue > 0,
            });

            AppLogger.debug('Stock updated for bundle ${item.batchId}.');
          } else {
            AppLogger.debug('Processing batch item: ${item.batchId}');
            final batchRef = _firestore
                .collection(FirestoreConstants.batches)
                .doc(item.batchId);

            final batchSnapshot = await transaction.get(batchRef);

            if (!batchSnapshot.exists) {
              AppLogger.error('Batch ${item.batchId} does not exist.');
              throw Exception('Batch ${item.batchId} does not exist.');
            }

            double currentStock =
                batchSnapshot['stock']?.toDouble() ?? 0.0;
            double newStockValue = currentStock - item.quantity;

            if (newStockValue < 0) {
              AppLogger.error(
                  'Insufficient stock for batch ${item.batchId}.');
              throw Exception(
                  'Insufficient stock for batch ${item.batchId}. Cannot fulfill order.');
            }

            transaction.update(batchRef, {
              FirestoreConstants.stock: newStockValue,
              FirestoreConstants.isListed: newStockValue > 0,
            });

            AppLogger.debug('Stock updated for batch ${item.batchId}.');
          }
        });
      }

      final orderRef = _firestore
          .collection(FirestoreConstants.orders)
          .doc(orderId);

      await _firestore.runTransaction((transaction) async {
        transaction.update(orderRef, {
          'pickupCode': pickupCode,
          FirestoreConstants.status: StatusConstants.ready,
        });
      });

      AppLogger.debug('Order $orderId fulfilled with pickup code $pickupCode.');
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to fulfill order', e, stackTrace);
      throw FirestoreException('Failed to fulfill order', originalError: e);
    }
  }

  @override
  Future<void> completeOrder(String orderId) async {
    try {
      final now = Timestamp.now();
      final orderRef = _firestore
          .collection(FirestoreConstants.orders)
          .doc(orderId);

      final orderDoc = await orderRef.get();

      if (!orderDoc.exists) {
        AppLogger.debug('No order found with ID: $orderId');
        throw FirestoreException('Order not found');
      }

      final String buyerId = orderDoc['buyerId'];
      final double totalPrice =
          orderDoc['totalPrice']?.toDouble() ?? 0.0;

      final userRef = _firestore
          .collection(FirestoreConstants.users)
          .doc(buyerId);

      await _firestore.runTransaction((transaction) async {
        transaction.update(orderRef, {
          FirestoreConstants.status: StatusConstants.completed,
          'completedAt': now,
          'isPaid': true,
        });

        final double transactionFee = double.parse(
            (totalPrice * AppConstants.transactionFeePercent)
                .toStringAsFixed(2));
        final double sellerEarnings =
            double.parse((totalPrice - transactionFee).toStringAsFixed(2));

        final int earnedPoints = (totalPrice / 200).floor();

        transaction.update(userRef, {
          'points': FieldValue.increment(earnedPoints),
        });

        final Map<String, dynamic> transactionData = {
          'date': FieldValue.serverTimestamp(),
          'isPaid': orderDoc['isPaid'],
          'orderId': orderDoc['orderId'],
          'sellerEarnings': sellerEarnings,
          'sellerId': orderDoc['sellerId'],
          'transactionFee': transactionFee,
          'type': StatusConstants.sale,
        };

        transaction.set(
          _firestore.collection(FirestoreConstants.transactions).doc(),
          transactionData,
        );

        AppLogger.debug(
            'Order $orderId completed. Seller earnings: ₱$sellerEarnings. User earned $earnedPoints points.');
      });
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to complete order', e, stackTrace);
      throw FirestoreException('Failed to complete order', originalError: e);
    }
  }
}
