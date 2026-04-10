import 'package:unshelf_seller/models/order_model.dart';

abstract class IOrderService {
  Future<OrderModel?> getOrder(String orderId);
  Future<List<OrderModel>> getOrders(bool forToday);
  Future<List<OrderModel>> getOrdersWithBatchId();
  Future<void> approveOrder(String orderId);
  Future<void> cancelOrder(String orderId);
  Future<void> fulfillOrder(String orderId, List<OrderItem> items, String pickupCode);
  Future<void> completeOrder(String orderId);
}
