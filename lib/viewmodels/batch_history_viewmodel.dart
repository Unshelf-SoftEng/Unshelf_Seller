import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/models/order_model.dart';
import 'package:unshelf_seller/services/order_service.dart';
import 'package:nanoid/nanoid.dart';
import 'package:unshelf_seller/services/product_service.dart';

class BatchHistoryViewModel extends ChangeNotifier {
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

  bool get isLoading => _isLoading;
  bool _isLoading = false;

  final OrderService _orderService = OrderService();

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
      ordersToReturn.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
    } else if (_sortOrder == 'Descending') {
      ordersToReturn.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    }

    return ordersToReturn;
  }

  Future<void> fetchBatchHistory(batchId) async {
    _isLoading = true;
    notifyListeners();
    _orders = await _orderService.getOrdersWithBatchId();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchOrdersHistory() async {
    _isLoading = true;
    notifyListeners();
    _orders = await _orderService.getOrders(false);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectOrder(String orderId) async {
    _isLoading = true;
    notifyListeners();
    _selectedOrder = await _orderService.getOrder(orderId);
    _isLoading = false;
    notifyListeners();
  }

  void filterOrdersByStatus(String? status) {
    _currentStatus = status!;
    notifyListeners();
  }

  Future<void> approveOrder() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_selectedOrder == null || _selectedOrder?.buyerId == null) {
        throw Exception("Order or buyer information is missing.");
      }

      final orderRef = FirebaseFirestore.instance
          .collection('orders')
          .doc(_selectedOrder?.id);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(orderRef, {
          'status': 'Processing',
        });
      });

      _selectedOrder!.status = 'Processing';
      _orders.firstWhere((order) => order.id == _selectedOrder?.id).status =
          'Processing';

      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelOrder() async {
    _isLoading = true;
    notifyListeners();

    var now = Timestamp.now();

    try {
      if (_selectedOrder == null || _selectedOrder?.buyerId == null) {
        throw Exception("Order or buyer information is missing.");
      }

      final orderRef = FirebaseFirestore.instance
          .collection('orders')
          .doc(_selectedOrder?.id);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(orderRef, {
          'status': 'Cancelled',
          'cancelledAt': now,
        });
      });

      _selectedOrder!.status = 'Cancelled';
      _selectedOrder!.cancelledAt = now;
      var updateOrder =
          _orders.firstWhere((order) => order.id == _selectedOrder?.id);

      updateOrder.status = 'Cancelled';
      updateOrder.cancelledAt = now;

      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fulfillOrder() async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_selectedOrder == null || _selectedOrder?.buyerId == null) {
        print('Order or buyer information is missing.');
        throw Exception("Order or buyer information is missing.");
      }

      final orderRef = FirebaseFirestore.instance
          .collection('orders')
          .doc(_selectedOrder?.id);

      var pickupCode = generatePickUpCode();
      _selectedOrder!.pickupCode = pickupCode;

      // Split item processing into smaller transactions if necessary
      for (var item in _selectedOrder!.items) {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          if (item.isBundle!) {
            print('Processing item: ${item.batchId}');
            final bundleRef = FirebaseFirestore.instance
                .collection('bundles')
                .doc(item.batchId);

            DocumentSnapshot bundleSnapshot = await transaction.get(bundleRef);

            print('Batch snapshot: ${bundleSnapshot.data()}');

            if (!bundleSnapshot.exists) {
              print('Bundle ${item.batchId} does not exist.');
              throw Exception("Bundle ${item.batchId} does not exist.");
            }

            double currentStock = bundleSnapshot['stock']?.toDouble() ?? 0.0;
            int quantity = item.quantity;
            double newStockValue = currentStock - quantity;

            if (newStockValue < 0) {
              print('Insufficient stock for batch ${item.batchId}.');
              throw Exception(
                  "Insufficient stock for batch ${item.batchId}. Cannot fulfill order.");
            }

            transaction.update(bundleRef, {
              'stock': newStockValue,
              'isListed': newStockValue > 0,
            });

            print('Stock updated for bundle ${item.batchId}.');
          } else {
            print('Processing item: ${item.batchId}');
            final batchRef = FirebaseFirestore.instance
                .collection('batches')
                .doc(item.batchId);

            DocumentSnapshot batchSnapshot = await transaction.get(batchRef);

            print('Batch snapshot: ${batchSnapshot.data()}');

            if (!batchSnapshot.exists) {
              print('Batch ${item.batchId} does not exist.');
              throw Exception("Batch ${item.batchId} does not exist.");
            }

            double currentStock = batchSnapshot['stock']?.toDouble() ?? 0.0;
            int quantity = item.quantity;
            double newStockValue = currentStock - quantity;

            if (newStockValue < 0) {
              print('Insufficient stock for batch ${item.batchId}.');
              throw Exception(
                  "Insufficient stock for batch ${item.batchId}. Cannot fulfill order.");
            }

            transaction.update(batchRef, {
              'stock': newStockValue,
              'isListed': newStockValue > 0,
            });

            print('Stock updated for batch ${item.batchId}.');
          }
        });
      }

      // After processing all items, update the order status
      final orderUpdate = {
        'pickupCode': pickupCode,
        'status': 'Ready',
      };

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(orderRef, orderUpdate);
      });

      _selectedOrder!.status = 'Ready';
      _selectedOrder!.pickupCode = pickupCode;

      var updateOrder =
          _orders.firstWhere((order) => order.id == _selectedOrder?.id);

      updateOrder.status = 'Ready';
      updateOrder.pickupCode = pickupCode;

      notifyListeners();
    } catch (e) {
      print("Error during order fulfillment: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String generatePickUpCode() {
    return customAlphabet('1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ', 8);
  }

  Future<void> completeOrder() async {
    try {
      Timestamp now = Timestamp.now();
      DocumentReference orderRef = FirebaseFirestore.instance
          .collection('orders')
          .doc(_selectedOrder?.id);

      // Fetch the order data
      DocumentSnapshot orderDoc = await orderRef.get();

      // Check if the order exists
      if (!orderDoc.exists) {
        print('No order found with ID: ${_selectedOrder?.id}');
        return;
      }

      // Get buyerId and totalPrice safely
      String buyerId = orderDoc['buyerId'];
      double totalPrice = orderDoc['totalPrice']?.toDouble() ?? 0.0;

      // Reference to the user document
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(buyerId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(orderRef, {
          'status': 'Completed',
          'completedAt': now,
          'isPaid': true,
        });

        double transactionFee =
            double.parse((totalPrice * 0.02).toStringAsFixed(2));
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
          'type': 'Sale',
        };

        transaction.set(
          FirebaseFirestore.instance.collection('transactions').doc(),
          transactionData,
        );

        print(
            'Order completed. Seller earnings: ₱$sellerEarnings. User earned $earnedPoints points.');
        _selectedOrder!.status = 'Completed';
        _selectedOrder!.completedAt = now;
        _selectedOrder!.isPaid = true;

        var updateOrder =
            _orders.firstWhere((order) => order.id == _selectedOrder?.id);

        updateOrder.status = 'Completed';
        updateOrder.completedAt = now;
        updateOrder.isPaid = true;
      });

      notifyListeners();
    } catch (e) {
      print('Error completing order: $e');
    }
  }

  final Map<String, Map<String, dynamic>> batchHistory = {
    // Existing Batches
    'LZOQUrGi4EhT5yV4jyA0': {
      'totalSaleSize': 13041.39 * 2,
      'totalProductsSold': 2,
      'orderHistory': [
        {
          'orderId': '20241216-003',
          'soldWithBundle': true,
          'soldQuantity': 1,
          'soldPrice': 13041.39,
        },
        {
          'orderId': '20241217-001',
          'soldWithBundle': false,
          'soldQuantity': 1,
          'soldPrice': 13041.39,
        },
      ],
    },
    'LZOQUrGi4EhT5yV4jyA0_3': {
      'totalSaleSize': 200.00 * 30,
      'totalProductsSold': 30,
      'batchNumber': 'BATCH125',
      'orderHistory': [
        {
          'orderId': '20241216-005',
          'soldWithBundle': true,
          'soldQuantity': 30,
          'soldPrice': 200.00,
        },
      ],
    },

    // New Batches
    '20241031-0': {
      'totalSaleSize': 1500.00 * 5,
      'totalProductsSold': 5,
      'orderHistory': [
        {
          'orderId': '20241031-001',
          'soldWithBundle': false,
          'soldQuantity': 5,
          'soldPrice': 1500.00,
        },
      ],
    },
    '20241031-1': {
      'totalSaleSize': 1200.00 * 8,
      'totalProductsSold': 8,
      'orderHistory': [
        {
          'orderId': '20241031-002',
          'soldWithBundle': true,
          'soldQuantity': 8,
          'soldPrice': 1200.00,
        },
      ],
    },
    '20241031-2': {
      'totalSaleSize': 800.00 * 3,
      'totalProductsSold': 3,
      'orderHistory': [
        {
          'orderId': '20241031-003',
          'soldWithBundle': false,
          'soldQuantity': 3,
          'soldPrice': 800.00,
        },
      ],
    },
    '20241205-0': {
      'totalSaleSize': 30 * 4,
      'totalProductsSold': 4,
      'orderHistory': [
        {
          'orderId': '20241205-001',
          'soldWithBundle': true,
          'soldQuantity': 4,
          'soldPrice': 30.00,
        },
      ],
    },
    '20241205-1': {
      'totalSaleSize': 33 * 2,
      'totalProductsSold': 2,
      'orderHistory': [
        {
          'orderId': '20241205-002',
          'soldWithBundle': false,
          'soldQuantity': 2,
          'soldPrice': 33.00,
        },
      ],
    },
    '20241214-0': {
      'totalSaleSize': 1000.00 * 10,
      'totalProductsSold': 10,
      'orderHistory': [
        {
          'orderId': '20241214-001',
          'soldWithBundle': true,
          'soldQuantity': 10,
          'soldPrice': 1000.00,
        },
      ],
    },
    '20241215-0': {
      'totalSaleSize': 750.00 * 6,
      'totalProductsSold': 6,
      'orderHistory': [
        {
          'orderId': '20241215-001',
          'soldWithBundle': false,
          'soldQuantity': 6,
          'soldPrice': 750.00,
        },
      ],
    },
  };
}
