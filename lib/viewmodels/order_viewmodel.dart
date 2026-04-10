import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nanoid/nanoid.dart';

import 'package:unshelf_seller/core/base_viewmodel.dart';
import 'package:unshelf_seller/core/logger.dart';
import 'package:unshelf_seller/core/constants/app_constants.dart';
import 'package:unshelf_seller/core/constants/firestore_constants.dart';
import 'package:unshelf_seller/core/constants/status_constants.dart';
import 'package:unshelf_seller/core/interfaces/i_order_service.dart';
import 'package:unshelf_seller/models/order_model.dart';

class OrderViewModel extends BaseViewModel {
  final IOrderService _orderService;

  OrderViewModel({required IOrderService orderService})
      : _orderService = orderService;

  List<OrderModel> _orders = [];
  String _currentStatus = 'All';
  OrderModel? _selectedOrder;
  OrderModel? get selectedOrder => _selectedOrder;
  List<OrderModel> get orders => _orders;
  String get currentStatus => _currentStatus;
  set currentStatus(String status) {
    _currentStatus = status;

    notifyListeners();
  }

  String get sortOrder => _sortOrder;
  set sortOrder(String order) {
    _sortOrder = order;

    notifyListeners();
  }

  String _sortOrder = 'Descending';

  List<OrderModel> get filteredOrders {
    List<OrderModel> ordersToReturn;

    // Filter by status
    if (_currentStatus == 'All') {
      ordersToReturn = _orders;
    } else {
      ordersToReturn =
          _orders.where((order) => order.status == _currentStatus).toList();
    }

    // Sort by createdAt in the specified order
    if (_sortOrder == 'Ascending') {
      ordersToReturn.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else if (_sortOrder == 'Descending') {
      ordersToReturn.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return ordersToReturn;
  }

  Future<void> fetchOrders() async {
    setLoading(true);
    AppLogger.debug('Fetching orders for today...');
    _orders = await _orderService.getOrders(true);
    setLoading(false);
  }

  Future<void> fetchOrdersHistory() async {
    setLoading(true);
    _orders = await _orderService.getOrders(false);
    setLoading(false);
  }

  Future<void> selectOrder(String orderId) async {
    setLoading(true);
    _selectedOrder = await _orderService.getOrder(orderId);
    setLoading(false);
  }

  void filterOrdersByStatus(String? status) {
    _currentStatus = status!;
    notifyListeners();
  }

  Future<void> approveOrder() async {
    setLoading(true);

    try {
      if (_selectedOrder == null || _selectedOrder?.buyerId == null) {
        throw Exception("Order or buyer information is missing.");
      }

      final orderRef = FirebaseFirestore.instance
          .collection(FirestoreConstants.orders)
          .doc(_selectedOrder?.id);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(orderRef, {
          FirestoreConstants.status: StatusConstants.processing,
        });
      });

      _selectedOrder!.status = StatusConstants.processing;
      _orders.firstWhere((order) => order.id == _selectedOrder?.id).status =
          StatusConstants.processing;

      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> cancelOrder() async {
    setLoading(true);

    var now = Timestamp.now();

    try {
      if (_selectedOrder == null || _selectedOrder?.buyerId == null) {
        throw Exception("Order or buyer information is missing.");
      }

      final orderRef = FirebaseFirestore.instance
          .collection(FirestoreConstants.orders)
          .doc(_selectedOrder?.id);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(orderRef, {
          FirestoreConstants.status: StatusConstants.cancelled,
          'cancelledAt': now,
        });
      });

      _selectedOrder!.status = StatusConstants.cancelled;
      _selectedOrder!.cancelledAt = now;
      var updateOrder =
          _orders.firstWhere((order) => order.id == _selectedOrder?.id);

      updateOrder.status = StatusConstants.cancelled;
      updateOrder.cancelledAt = now;

      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> fulfillOrder() async {
    setLoading(true);
    try {
      if (_selectedOrder == null || _selectedOrder?.buyerId == null) {
        AppLogger.error('Order or buyer information is missing.');
        throw Exception("Order or buyer information is missing.");
      }

      final orderRef = FirebaseFirestore.instance
          .collection(FirestoreConstants.orders)
          .doc(_selectedOrder?.id);

      var pickupCode = generatePickUpCode();
      _selectedOrder!.pickupCode = pickupCode;

      // Split item processing into smaller transactions if necessary
      for (var item in _selectedOrder!.items) {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          if (item.isBundle!) {
            AppLogger.debug('Processing item: ${item.batchId}');
            final bundleRef = FirebaseFirestore.instance
                .collection(FirestoreConstants.bundles)
                .doc(item.batchId);

            DocumentSnapshot bundleSnapshot = await transaction.get(bundleRef);

            AppLogger.debug('Batch snapshot: ${bundleSnapshot.data()}');

            if (!bundleSnapshot.exists) {
              AppLogger.error('Bundle ${item.batchId} does not exist.');
              throw Exception("Bundle ${item.batchId} does not exist.");
            }

            double currentStock = bundleSnapshot['stock']?.toDouble() ?? 0.0;
            int quantity = item.quantity;
            double newStockValue = currentStock - quantity;

            if (newStockValue < 0) {
              AppLogger.error(
                  'Insufficient stock for batch ${item.batchId}.');
              throw Exception(
                  "Insufficient stock for batch ${item.batchId}. Cannot fulfill order.");
            }

            transaction.update(bundleRef, {
              'stock': newStockValue,
              'isListed': newStockValue > 0,
            });

            AppLogger.debug('Stock updated for bundle ${item.batchId}.');
          } else {
            AppLogger.debug('Processing item: ${item.batchId}');
            final batchRef = FirebaseFirestore.instance
                .collection(FirestoreConstants.batches)
                .doc(item.batchId);

            DocumentSnapshot batchSnapshot = await transaction.get(batchRef);

            AppLogger.debug('Batch snapshot: ${batchSnapshot.data()}');

            if (!batchSnapshot.exists) {
              AppLogger.error('Batch ${item.batchId} does not exist.');
              throw Exception("Batch ${item.batchId} does not exist.");
            }

            double currentStock = batchSnapshot['stock']?.toDouble() ?? 0.0;
            int quantity = item.quantity;
            double newStockValue = currentStock - quantity;

            if (newStockValue < 0) {
              AppLogger.error(
                  'Insufficient stock for batch ${item.batchId}.');
              throw Exception(
                  "Insufficient stock for batch ${item.batchId}. Cannot fulfill order.");
            }

            transaction.update(batchRef, {
              'stock': newStockValue,
              'isListed': newStockValue > 0,
            });

            AppLogger.debug('Stock updated for batch ${item.batchId}.');
          }
        });
      }

      // After processing all items, update the order status
      final orderUpdate = {
        'pickupCode': pickupCode,
        FirestoreConstants.status: StatusConstants.ready,
      };

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(orderRef, orderUpdate);
      });

      _selectedOrder!.status = StatusConstants.ready;
      _selectedOrder!.pickupCode = pickupCode;

      var updateOrder =
          _orders.firstWhere((order) => order.id == _selectedOrder?.id);

      updateOrder.status = StatusConstants.ready;
      updateOrder.pickupCode = pickupCode;

      notifyListeners();
    } catch (e) {
      AppLogger.error('Error during order fulfillment: $e');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  String generatePickUpCode() {
    return customAlphabet('1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ', 8);
  }

  Future<void> completeOrder() async {
    try {
      Timestamp now = Timestamp.now();
      DocumentReference orderRef = FirebaseFirestore.instance
          .collection(FirestoreConstants.orders)
          .doc(_selectedOrder?.id);

      // Fetch the order data
      DocumentSnapshot orderDoc = await orderRef.get();

      // Check if the order exists
      if (!orderDoc.exists) {
        AppLogger.debug('No order found with ID: ${_selectedOrder?.id}');
        return;
      }

      // Get buyerId and totalPrice safely
      String buyerId = orderDoc['buyerId'];
      double totalPrice = orderDoc['totalPrice']?.toDouble() ?? 0.0;

      // Reference to the user document
      DocumentReference userRef = FirebaseFirestore.instance
          .collection(FirestoreConstants.users)
          .doc(buyerId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(orderRef, {
          FirestoreConstants.status: StatusConstants.completed,
          'completedAt': now,
          'isPaid': true,
        });

        double transactionFee = double.parse(
            (totalPrice * AppConstants.transactionFeePercent)
                .toStringAsFixed(2));
        double sellerEarnings =
            double.parse((totalPrice - transactionFee).toStringAsFixed(2));

        int earnedPoints = (totalPrice / 200).floor();

        // Update user's points in Firestore
        transaction.update(userRef, {
          'points': FieldValue.increment(earnedPoints),
        });

        // Prepare the transaction data
        Map<String, dynamic> transactionData = {
          'date': FieldValue.serverTimestamp(),
          'isPaid': orderDoc['isPaid'],
          'orderId': orderDoc['orderId'],
          'sellerEarnings': sellerEarnings,
          'sellerId': orderDoc['sellerId'],
          'transactionFee': transactionFee,
          'type': StatusConstants.sale,
        };

        transaction.set(
          FirebaseFirestore.instance
              .collection(FirestoreConstants.transactions)
              .doc(),
          transactionData,
        );

        AppLogger.debug(
            'Order completed. Seller earnings: ₱$sellerEarnings. User earned $earnedPoints points.');
        _selectedOrder!.status = StatusConstants.completed;
        _selectedOrder!.completedAt = now;
        _selectedOrder!.isPaid = true;

        var updateOrder =
            _orders.firstWhere((order) => order.id == _selectedOrder?.id);

        updateOrder.status = StatusConstants.completed;
        updateOrder.completedAt = now;
        updateOrder.isPaid = true;
      });

      notifyListeners();
    } catch (e) {
      AppLogger.error('Error completing order: $e');
    }
  }

  void clear() {
    _orders = [];
    _selectedOrder = null;
    _currentStatus = 'All';
    notifyListeners();
  }

  void clearSelectedOrder() {
    _selectedOrder = null;
    notifyListeners();
  }
}
