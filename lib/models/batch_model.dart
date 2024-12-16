import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/models/product_model.dart';

class BatchModel {
  String batchNumber;
  String productId;
  ProductModel? product;
  double price;
  int stock;
  String quantifier;
  DateTime expiryDate;
  int discount;

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

  // // Method to convert StoreModel to Json
  // Map<String, dynamic> toJson() {
  //   return {
  //     'productId': id,
  //     'name': name,
  //     'description': description,
  //     'price': price,
  //     'stock': stock,
  //     'expiryDate': expiryDate!.toIso8601String(),
  //     'discount': discount,
  //   };
  // }

  // factory ProductModel.fromJson(Map<String, dynamic> json) {
  //   return ProductModel(
  //     id: json['id'] ?? '',
  //     name: json['name'] ?? '',
  //     description: json['description'] ?? '',
  //     category: json['category'] ?? '',
  //     price: json['price'] ?? 0.0,
  //     quantifier: json['quantifier'] ?? '',
  //     stock: json['stock'] ?? 0,
  //     expiryDate: json['expiryDate'] != null
  //         ? DateTime.parse(json['expiryDate'])
  //         : DateTime.now(),
  //     discount: json['discount'] ?? 0,
  //     mainImageUrl: json['mainImageUrl'] ?? '',
  //   );
  // }
}
