import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/models/product_model.dart';

class BatchModel {
  final String batchNumber;
  final String productId;
  ProductModel? product;
  final double price;
  int stock;
  final String quantifier;
  DateTime expiryDate;
  final int discount;

  BatchModel({
    required this.batchNumber,
    required this.productId,
    required this.product,
    required this.price,
    required this.stock,
    required this.quantifier,
    required this.expiryDate,
    required this.discount,
  });

  Map<String, dynamic> toMap() {
    return {
      'batchNumber': batchNumber,
      'productId': productId,
      'price': price,
      'stock': stock,
      'quantifier': quantifier,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'discount': discount,
    };
  }

  factory BatchModel.fromSnapshot(DocumentSnapshot doc, ProductModel? product) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return BatchModel(
      batchNumber: doc.id,
      productId: data['productId'],
      product: product,
      price: (data['price'] as num).toDouble(),
      stock: (data['stock'] as num).toInt(),
      quantifier: data['quantifier'] ?? '',
      expiryDate: data['expiryDate'] != null
          ? (data['expiryDate'] as Timestamp).toDate()
          : DateTime.now(),
      discount: data['discount'] ?? 0,
    );
  }

}
