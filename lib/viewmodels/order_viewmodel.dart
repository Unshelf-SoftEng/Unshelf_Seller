// view_models/orders_view_model.dart
import 'package:flutter/foundation.dart';
import 'package:unshelf_seller/models/order_model.dart';

class OrderViewModel extends ChangeNotifier {
  List<OrderModel> _orders = [];
  OrderModel? _selectedOrder;
  OrderModel? get selectedOrder => _selectedOrder;
  List<OrderModel> get orders => _orders;

  void fetchOrders() {
    // Simulate fetching data from a repository or API
    _orders = [
      OrderModel(id: '1', item: 'Item A', quantity: 2),
      OrderModel(id: '2', item: 'Item B', quantity: 1),
      OrderModel(id: '3', item: 'Item C', quantity: 5),
    ];
    notifyListeners();
  }

  void selectOrder(String id) {
    _selectedOrder = _orders.firstWhere(
      (order) => order.id == id,
      orElse: () => OrderModel(id: '', item: '', quantity: 0),
    );
    notifyListeners();
  }
}
