import 'package:flutter/foundation.dart';
import 'package:unshelf_seller/models/order_model.dart';

class OrderViewModel extends ChangeNotifier {
  List<OrderModel> _orders = [];
  OrderStatus _currentStatus = OrderStatus.all;
  OrderModel? _selectedOrder;
  OrderModel? get selectedOrder => _selectedOrder;
  List<OrderModel> get orders => _orders;
  OrderStatus get currentStatus =>
      _currentStatus; // Added to get the current filter status

  List<OrderModel> get filteredOrders {
    if (_currentStatus == OrderStatus.all) {
      return _orders;
    }
    return _orders.where((order) => order.status == _currentStatus).toList();
  }

  void fetchOrders() {
    // Simulate fetching data from a repository or API
    _orders = [
      OrderModel(
          id: '1', item: 'Item A', quantity: 2, status: OrderStatus.pending),
      OrderModel(
          id: '2', item: 'Item B', quantity: 1, status: OrderStatus.completed),
      OrderModel(
          id: '3', item: 'Item C', quantity: 5, status: OrderStatus.shipped),
    ];
    notifyListeners();
  }

  OrderModel? selectOrder(String orderId) {
    _selectedOrder = _orders.firstWhere((order) => order.id == orderId);
    notifyListeners();
    return _selectedOrder;
  }

  void setFilter(OrderStatus status) {
    _currentStatus = status; // Update the current filter status
    notifyListeners();
  }
}
