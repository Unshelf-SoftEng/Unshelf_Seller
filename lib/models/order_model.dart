import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/models/product_model.dart';

class OrderModel {
  final String id;
  final String orderId;
  final String buyerId;
  final List<OrderItem> items;
  String status;
  final Timestamp createdAt;
  final bool isPaid;
  List<ProductModel> products = [];
  double totalPrice;
  String buyerName;
  Timestamp? completionDate;
  String? pickUpCode;

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
    this.completionDate,
    this.pickUpCode = '',
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return OrderModel(
      id: doc.id,
      orderId: data['order_id'],
      status: data['status'],
      createdAt: data['created_at'] as Timestamp,
      completionDate: data['completion_date'] as Timestamp?,
      pickUpCode: data['pick_up_code'] as String?,
      buyerId: data['buyer_id'],
      items: List<OrderItem>.from(
        data['order_items'].map((item) => OrderItem.fromMap(item)),
      ),
      totalPrice: data['totalPrice'],
      isPaid: data['isPaid'],
      products: [],
    );
  }

  static Future<OrderModel> fetchOrderWithProducts(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;

    final orderModel = OrderModel(
      id: doc.id,
      orderId: data['orderId'],
      status: data['status'],
      createdAt: data['createdAt'] as Timestamp,
      buyerId: data['buyerId'],
      items: List<OrderItem>.from(
        data['orderItems'].map((item) => OrderItem.fromMap(item)),
      ),
      products: [],
      completionDate: data['completedAt'] as Timestamp?,
      pickUpCode: data['pickupCode'] as String?,
      totalPrice: data['totalPrice'],
      isPaid: data['isPaid'],
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
      orderId: orderModel.orderId,
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
      isPaid: orderModel.isPaid,
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
      productId: map['productId'],
    );
  }
}
