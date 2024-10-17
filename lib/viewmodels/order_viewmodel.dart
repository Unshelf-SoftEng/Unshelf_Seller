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

      _orders = await Future.wait<OrderModel>(querySnapshot.docs
          .map((doc) => OrderModel.fetchOrderWithProducts(doc))
          .toList());

      print(_orders);

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
        .update({'pickupCode': code});
  }

  void clear() {
    _orders = [];
    _selectedOrder = null;
    _currentStatus = 'All';
    notifyListeners();
  }
}
