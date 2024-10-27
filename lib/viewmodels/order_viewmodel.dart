import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/models/order_model.dart';
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
    _isLoading = true;
    notifyListeners();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('sellerId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Failed to fetch orders: $e');
    }
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
    _selectedOrder?.status = 'Ready';

    // Update the order status in Firestore
    FirebaseFirestore.instance
        .collection('orders')
        .doc(_selectedOrder?.id)
        .update({'status': 'Ready'});

    _selectedOrder?.items.forEach((item) async {
      final productRef =
          FirebaseFirestore.instance.collection('products').doc(item.productId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot productDoc = await transaction.get(productRef);
        double currentStock = productDoc['stock']; // Get the latest stock value
        int quantity = item.quantity;
        double newStockValue = currentStock - quantity;
        DocumentReference orderRef = FirebaseFirestore.instance
            .collection('orders')
            .doc(_selectedOrder?.id);

        if (newStockValue < 0) {
          print("Insufficient stock. Cannot complete order.");
          return; // Abort the operation
        }

        transaction.update(orderRef, {'status': 'Completed'});
        transaction
            .update(orderRef, {'completedAt': FieldValue.serverTimestamp()});
        transaction.update(productRef, {'stock': newStockValue});
        transaction.update(productRef, {'isListed': newStockValue > 0});
      });
    });

    generatePickUpCode();

    notifyListeners();
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
