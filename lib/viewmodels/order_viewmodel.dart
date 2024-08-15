import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/models/order_model.dart';
import 'package:nanoid/nanoid.dart';

class OrderViewModel extends ChangeNotifier {
  List<OrderModel> _orders = [];
  OrderStatus _currentStatus = OrderStatus.all;
  OrderModel? _selectedOrder;
  OrderModel? get selectedOrder => _selectedOrder;
  List<OrderModel> get orders => _orders;
  OrderStatus get currentStatus => _currentStatus;

  bool get isLoading => _isLoading;
  bool _isLoading = false;

  late Future<void> fetchOrdersFuture;

  OrderViewModel() {
    fetchOrdersFuture = fetchOrders();
  }

  List<OrderModel> get filteredOrders {
    if (_currentStatus == OrderStatus.all) {
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
          .where('seller_id', isEqualTo: user.uid)
          .orderBy('created_at', descending: true)
          .get();

      _orders = await Future.wait<OrderModel>(querySnapshot.docs
          .map((doc) => OrderModel.fetchOrderWithProducts(doc))
          .toList());

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
    if (status == null || status == 'All') {
      _currentStatus = OrderStatus.all;
    } else if (status == 'Pending') {
      // Filter orders based on status
      _currentStatus = OrderStatus.pending;
    } else if (status == 'Completed') {
      _currentStatus = OrderStatus.completed;
    } else if (status == 'Ready') {
      _currentStatus = OrderStatus.ready;
    }
    notifyListeners();
  }

  Future<void> fulfillOrder() async {
    _selectedOrder?.status = OrderStatus.ready;

    // Update the order status in Firestore
    FirebaseFirestore.instance
        .collection('orders')
        .doc(_selectedOrder?.id)
        .update({'status': 'Ready'});

    // Update the product stock in Firestore
    _selectedOrder?.items.forEach((item) async {
      final productRef =
          FirebaseFirestore.instance.collection('products').doc(item.productId);

      // Use a transaction for safe stock updates
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Get the latest stock value within the transaction
        final snapshot = await transaction.get(productRef);
        final currentStock = snapshot.get('stock');

        final newStock = currentStock - item.quantity;

        // Update the stock within the transaction
        transaction.update(productRef, {
          'stock': newStock,
        });

        if (newStock == 0) {
          transaction.update(productRef, {
            'isListed': false,
          });
        }
      });
    });

    print('Order ${_selectedOrder?.id} fulfilled');

    generatePickUpCode();

    notifyListeners();
  }

  void generatePickUpCode() {
    // Use the nanoid library to generate a short, unique, and URL-safe code
    final code = customAlphabet('1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ', 8);

    _selectedOrder?.pickUpCode = code;

    // Update the pick up code in Firestore
    FirebaseFirestore.instance
        .collection('orders')
        .doc(_selectedOrder?.id)
        .update({'pick_up_code': code});

    print('Pick up code: $code');
  }

  void clear() {
    _orders = [];
    _selectedOrder = null;
    _currentStatus = OrderStatus.all;
    notifyListeners();
  }
}
