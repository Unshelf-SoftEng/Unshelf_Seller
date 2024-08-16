import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/models/product_model.dart';

enum OrderStatus { all, pending, ready, completed }

OrderStatus orderStatusFromString(String status) {
  switch (status) {
    case 'Pending':
      return OrderStatus.pending;
    case 'Completed':
      return OrderStatus.completed;
    case 'Ready':
      return OrderStatus.ready;
    default:
      throw Exception('Unknown order status: $status');
  }
}

class OrderModel {
  final String id;
  final String buyerId;
  final List<OrderItem> items;
  OrderStatus status;
  final Timestamp createdAt;
  List<ProductModel> products = [];
  double totalPrice;
  String buyerName;
  Timestamp? completionDate;
  String? pickUpCode;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.items,
    required this.status,
    required this.createdAt,
    this.totalPrice = 0,
    this.products = const [],
    this.buyerName = '',
    this.completionDate,
    this.pickUpCode = '',
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return OrderModel(
      id: doc.id,
      status: orderStatusFromString(data['status'] as String),
      createdAt: data['created_at'] as Timestamp,
      completionDate: data['completion_date'] as Timestamp?,
      pickUpCode: data['pick_up_code'] as String?,
      buyerId: data['buyer_id'],
      items: List<OrderItem>.from(
        data['order_items'].map((item) => OrderItem.fromMap(item)),
      ),
      products: [],
    );
  }

  static Future<OrderModel> fetchOrderWithProducts(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;

    final orderModel = OrderModel(
      id: doc.id,
      status: orderStatusFromString(data['status'] as String),
      createdAt: data['created_at'] as Timestamp,
      buyerId: data['buyer_id'],
      items: List<OrderItem>.from(
        data['order_items'].map((item) => OrderItem.fromMap(item)),
      ),
      products: [],
      completionDate: data['completion_date'] as Timestamp?,
      pickUpCode: data['pick_up_code'] as String?,
    );

    List<String> productIds =
        orderModel.items.map((item) => item.productId).toList();

    final productSnapshots = await FirebaseFirestore.instance
        .collection('products')
        .where(FieldPath.documentId, whereIn: productIds)
        .get();

    List<ProductModel> products = productSnapshots.docs.map((doc) {
      return ProductModel.fromSnapshot(doc);
    }).toList();

    DocumentSnapshot buyerSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(orderModel.buyerId)
        .get();

    if (buyerSnapshot.exists) {
      orderModel.buyerName = buyerSnapshot.get('name');
    } else {
      // Handle the case where the document does not exist
      print('Buyer document does not exist');
    }

    // Return a new OrderModel with the populated products
    return OrderModel(
      id: orderModel.id,
      status: orderModel.status,
      createdAt: orderModel.createdAt,
      buyerId: orderModel.buyerId,
      items: orderModel.items,
      products: products,
      totalPrice: products.fold<double>(
        0,
        (previousValue, element) => previousValue + element.price,
      ),
      buyerName: orderModel.buyerName,
      completionDate: orderModel.completionDate,
      pickUpCode: orderModel.pickUpCode,
    );
  }
}

class OrderItem {
  final int quantity;
  final String productId;

  OrderItem({
    required this.quantity,
    required this.productId,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      quantity: map['quantity'] as int,
      productId: map['product_id'],
    );
  }
}
