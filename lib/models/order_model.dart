enum OrderStatus { all, pending, completed, shipped }

class OrderModel {
  final String id;
  final String item;
  final int quantity;

  final OrderStatus status;

  OrderModel({
    required this.id,
    required this.item,
    required this.quantity,
    required this.status,
  });
}
