import 'package:unshelf_seller/models/order_model.dart';

abstract class IOrderService {
  Future<OrderModel?> getOrder(String orderId);
  Future<List<OrderModel>> getOrders(bool forToday);
  Future<List<OrderModel>> getOrdersWithBatchId();
}
