import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nanoid/nanoid.dart';

import 'package:unshelf_seller/core/base_viewmodel.dart';
import 'package:unshelf_seller/core/constants/status_constants.dart';
import 'package:unshelf_seller/core/interfaces/i_batch_service.dart';
import 'package:unshelf_seller/core/interfaces/i_order_service.dart';
import 'package:unshelf_seller/models/batch_model.dart';
import 'package:unshelf_seller/models/order_model.dart';

class BatchHistoryViewModel extends BaseViewModel {
  final IOrderService _orderService;
  final IBatchService _batchService;

  BatchHistoryViewModel({
    required IOrderService orderService,
    required IBatchService batchService,
  })  : _orderService = orderService,
        _batchService = batchService;

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

  Future<void> fetchBatchHistory(batchId) async {
    setLoading(true);

    // ignore: unused_local_variable
    BatchModel? batch = await _batchService.getBatchById(batchId);
    _orders = await _orderService.getOrdersWithBatchId();

    double totalSaleSize = 0;
    int totalProductsSold = 0;
    int totalBatchStock = 0;

    for (var order in _orders) {
      for (var item in order.items) {
        if (item.batchId == batchId) {
          totalSaleSize += (item.price ?? 0) * item.quantity;
          totalProductsSold += item.quantity;
        }
      }
    }

    batchHistory[batchId] = {
      'totalSaleSize': totalSaleSize,
      'totalProductsSold': totalProductsSold,
      'totalBatchStock': totalBatchStock,
      'orderHistory': _orders,
    };

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
