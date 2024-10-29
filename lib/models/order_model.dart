import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/models/batch_model.dart';

class OrderModel {
  final String id;
  final String orderId;
  final String buyerId;
  final List<OrderItem> items;
  String status;
  final Timestamp createdAt;
  final bool isPaid;
  List<BatchModel> products = [];
  double totalPrice;
  String buyerName;
  Timestamp? completedAt;
  String? pickupCode;
  String? pickupTime;

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
    this.pickupCode = '',
    this.pickupTime = '',
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return OrderModel(
      id: doc.id,
      orderId: data['orderId'],
      status: data['status'],
      createdAt: data['createdAt'] as Timestamp,
      completedAt: data['completetedAt'] as Timestamp?,
      pickupCode: data['pickupCode'] as String?,
      pickupTime: data['pickupTime'],
      buyerId: data['buyer_id'],
      items: List<OrderItem>.from(
        data['orderItems'].map((item) => OrderItem.fromMap(item)),
      ),
      totalPrice: data['totalPrice'],
      isPaid: data['isPaid'],
      products: [],
    );
  }
}

class OrderItem {
  final int quantity;
  final String batchNumber;
  String? name;

  OrderItem({
    required this.batchNumber,
    required this.quantity,
    this.name,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      quantity: map['quantity'] as int,
      batchNumber: map['batchNumber'],
      name: map['name'],
    );
  }
}
