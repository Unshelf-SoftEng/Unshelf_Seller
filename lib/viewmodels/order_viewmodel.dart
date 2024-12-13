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
    _orders = await _orderService.getOrders();
    _isLoading = false;
  }

  OrderModel? selectOrder(String orderId) {
    _isLoading = true;
    _selectedOrder = _orders.firstWhere((order) => order.id == orderId);
    _isLoading = false;
    notifyListeners();
    return _selectedOrder;
  }

  void filterOrdersByStatus(String? status) {
    _currentStatus = status!;
    notifyListeners();
  }

  Future<void> fulfillOrder() async {
    try {
      // Ensure the order and buyer details exist
      if (_selectedOrder == null || _selectedOrder?.buyerId == null) {
        throw Exception("Order or buyer information is missing.");
      }

      // Mark order as 'Ready' initially
      _selectedOrder?.status = 'Ready';

      // Variables to calculate total order amount
      double totalOrderAmount = 0.0;

      // Begin transaction for all order items and points calculation
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        for (var item in _selectedOrder!.items) {
          final batchRef = FirebaseFirestore.instance
              .collection('batches')
              .doc(item.batchId);
          final orderRef = FirebaseFirestore.instance
              .collection('orders')
              .doc(_selectedOrder?.id);

          // Fetch product stock
          DocumentSnapshot productDoc = await transaction.get(batchRef);

          if (!productDoc.exists) {
            throw Exception("Batch ${item.batchId} does not exist.");
          }

          double currentStock = productDoc['stock'];
          int quantity = item.quantity;
          double newStockValue = currentStock - quantity;

          if (newStockValue < 0) {
            throw Exception(
                "Insufficient stock for batch ${item.batchId}. Cannot complete order.");
          }

          // Update stock and listing status
          transaction.update(batchRef, {'stock': newStockValue});
          transaction.update(batchRef, {'isListed': newStockValue > 0});

          // Calculate price
          double pricePerUnit = productDoc['price'];
          totalOrderAmount += pricePerUnit * quantity;

          // Update order to 'Completed' with completion timestamp
          transaction.update(orderRef, {'status': 'Completed'});
          transaction
              .update(orderRef, {'completedAt': FieldValue.serverTimestamp()});
        }

        if (totalOrderAmount > 0) {
          int earnedPoints = (totalOrderAmount / 200).floor();

          if (earnedPoints > 0) {
            final userRef = FirebaseFirestore.instance
                .collection('users')
                .doc(_selectedOrder?.buyerId);

            DocumentSnapshot userDoc = await transaction.get(userRef);

            if (!userDoc.exists) {
              throw Exception(
                  "User ${_selectedOrder?.buyerId} does not exist.");
            }

            int currentPoints = userDoc['points'] ?? 0;
            transaction
                .update(userRef, {'points': currentPoints + earnedPoints});

            print('User earned $earnedPoints points for this purchase.');
          }
        }
      });

      // Generate pickup code if the transaction succeeds
      generatePickUpCode();

      notifyListeners();
    } catch (e) {
      print("Error fulfilling order: $e");
      // Handle errors gracefully
      throw Exception("Transaction failed: $e");
    }
  }

  void generatePickUpCode() {
    // Use the nanoid library to generate a short, unique, and URL-safe code
    final code = customAlphabet('1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ', 8);

    _selectedOrder?.pickupCode = code;

    // Update the pick up code in Firestore
    FirebaseFirestore.instance
        .collection('orders')
        .doc(_selectedOrder?.id)
        .update({'pickupCode': code});
  }

  Future<void> completeOrder(String orderId) async {
    _selectedOrder?.status = 'Completed';
    try {
      DocumentReference orderRef =
          FirebaseFirestore.instance.collection('orders').doc(orderId);
      DocumentSnapshot orderDoc = await orderRef.get();

      // Check if any orders were found
      if (orderDoc.exists) {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          // Update the order status to 'Completed'
          transaction.update(orderRef, {'status': 'Completed'});
          transaction
              .update(orderRef, {'completedAt': FieldValue.serverTimestamp()});

          double transactionFee =
              double.parse((orderDoc['totalPrice'] * 0.02).toStringAsFixed(2));
          double sellerEarnings = double.parse(
              (orderDoc['totalPrice'] - transactionFee).toStringAsFixed(2));

          // Prepare the transaction data
          Map<String, dynamic> transactionData = {
            'date': FieldValue.serverTimestamp(),
            'isPaid': orderDoc['isPaid'],
            'orderId': orderId,
            'sellerEarnings': sellerEarnings,
            'sellerId': orderDoc['sellerId'],
            'transactionFee': transactionFee,
            'type': 'Sale',
          };

          transaction.set(
            FirebaseFirestore.instance.collection('transactions').doc(),
            transactionData,
          );
        });
        notifyListeners();
      } else {
        print('No order found with ID: $orderId');
      }
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
}
