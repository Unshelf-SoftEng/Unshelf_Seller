import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/models/order_model.dart';
import 'package:unshelf_seller/services/order_service.dart';
import 'package:nanoid/nanoid.dart';

class OrderViewModel extends ChangeNotifier {
  List<OrderModel> _orders = [];
  String _currentStatus = 'All';
  OrderModel? _selectedOrder;
  OrderModel? get selectedOrder => _selectedOrder;
  List<OrderModel> get orders => _orders;
  String get currentStatus => _currentStatus;

  bool get isLoading => _isLoading;
  bool _isLoading = false;

  late Future<void> fetchOrdersFuture;
  final OrderService _orderService = OrderService();

  OrderViewModel() {
    fetchOrdersFuture = fetchOrders();
  }

  List<OrderModel> get filteredOrders {
    if (_currentStatus == 'All') {
      return _orders;
    }
    return _orders.where((order) => order.status == _currentStatus).toList();
  }

  Future<void> fetchOrders() async {
    print('Fetching orders...');
    _isLoading = true;
    notifyListeners();
    _orders = await _orderService.getOrders();
    print('Orders fetched: ${_orders.length}');
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
          'cancelledAt': FieldValue.serverTimestamp(),
        });
      });

      _selectedOrder!.status = 'Cancelled';
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
      DateTime now = DateTime.now();
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
        _selectedOrder!.completedAt = Timestamp.fromDate(now);
        _selectedOrder!.isPaid = true;
      });

      notifyListeners();
    } catch (e) {
      print('Error completing order: $e');
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
