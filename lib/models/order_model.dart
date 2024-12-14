import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/models/batch_model.dart';

class OrderModel {
  final String id;
  final String orderId;
  final String buyerId;
  final List<OrderItem> items;
  String status;
  final Timestamp createdAt;
  bool isPaid;
  List<BatchModel> products = [];
  double totalPrice;
  String buyerName;
  Timestamp? completedAt;
  Timestamp? cancelledAt;
  String? pickupCode;
  Timestamp? pickupTime;

  OrderModel({
    required this.id,
    required this.orderId,
    required this.buyerId,
    required this.items,
    required this.status,
    required this.createdAt,
    required this.isPaid,
    this.totalPrice = 0,
    this.products = const [],
    this.buyerName = '',
    this.completedAt,
    this.cancelledAt,
    this.pickupCode = '',
    this.pickupTime,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return OrderModel(
      id: doc.id,
      orderId: data['orderId'] ?? '',
      status: data['status'] ?? '',
      createdAt: data['createdAt'] as Timestamp,
      completedAt: data['completedAt'] as Timestamp?,
      cancelledAt: data['cancelledAt'] as Timestamp?,
      pickupCode: data['pickupCode'] ?? '',
      pickupTime: data['pickupTime'] as Timestamp?,
      buyerId: data['buyerId'] ?? '',
      items: List<OrderItem>.from(
        data['orderItems'].map((item) => OrderItem.fromMap(item)),
      ),
      totalPrice: (data['totalPrice'] as num).toDouble(),
      isPaid: data['isPaid'] ?? false,
      products: [],
    );
  }
}

class OrderItem {
  final int quantity;
  final String? batchId;
  final String? bundleId;
  final double? price;
  String? name;

  OrderItem({
    required this.quantity,
    this.batchId,
    this.bundleId,
    this.price,
    this.name,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      quantity: map['quantity'] as int,
      batchId: map['batchId'] ?? '',
      bundleId: map['bundleId'] ?? '',
      price: (map['price'] as num?)?.toDouble(),
      name: map['name'] ?? '',
    );
  }
}
