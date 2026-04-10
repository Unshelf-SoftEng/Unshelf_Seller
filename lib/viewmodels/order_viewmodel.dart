import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nanoid/nanoid.dart';

import 'package:unshelf_seller/core/base_viewmodel.dart';
import 'package:unshelf_seller/core/logger.dart';
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
    await runBusyFuture(() async {
      await _orderService.approveOrder(_selectedOrder!.id);
      _selectedOrder!.status = StatusConstants.processing;
      _orders
          .firstWhere((o) => o.id == _selectedOrder!.id)
          .status = StatusConstants.processing;
    });
  }

  Future<void> cancelOrder() async {
    await runBusyFuture(() async {
      await _orderService.cancelOrder(_selectedOrder!.id);
      var now = Timestamp.now();
      _selectedOrder!.status = StatusConstants.cancelled;
      _selectedOrder!.cancelledAt = now;
      var updateOrder =
          _orders.firstWhere((o) => o.id == _selectedOrder!.id);
      updateOrder.status = StatusConstants.cancelled;
      updateOrder.cancelledAt = now;
    });
  }

  Future<void> fulfillOrder() async {
    await runBusyFuture(() async {
      var pickupCode = generatePickUpCode();
      await _orderService.fulfillOrder(
          _selectedOrder!.id, _selectedOrder!.items, pickupCode);
      _selectedOrder!.status = StatusConstants.ready;
      _selectedOrder!.pickupCode = pickupCode;
      var updateOrder =
          _orders.firstWhere((o) => o.id == _selectedOrder!.id);
      updateOrder.status = StatusConstants.ready;
      updateOrder.pickupCode = pickupCode;
    });
  }

  String generatePickUpCode() {
    return customAlphabet('1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ', 8);
  }

  Future<void> completeOrder() async {
    await runBusyFuture(() async {
      await _orderService.completeOrder(_selectedOrder!.id);
      var now = Timestamp.now();
      _selectedOrder!.status = StatusConstants.completed;
      _selectedOrder!.completedAt = now;
      _selectedOrder!.isPaid = true;
      var updateOrder =
          _orders.firstWhere((o) => o.id == _selectedOrder!.id);
      updateOrder.status = StatusConstants.completed;
      updateOrder.completedAt = now;
      updateOrder.isPaid = true;
    });
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
