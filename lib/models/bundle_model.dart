import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/models/product_model.dart';
import 'package:unshelf_seller/models/item_model.dart';

class BundleModel extends ItemModel {
  final String description;
  final double? price;
  final int? stock;
  final int? discount;
  final List<String>? additionalImageUrls;
  final List<Map<String, dynamic>> items;
  final List<ProductModel>? products;

  BundleModel({
    required super.id,
    required super.name,
    required super.mainImageUrl,
    required super.category,
    required this.description,
    required this.items,
    this.price,
    this.stock,
    this.discount,
    this.additionalImageUrls,
    this.products,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'items': items,
      'price': price,
      'stock': stock,
      'discount': discount,
      'mainImageUrl': mainImageUrl,
    };
  }

  // Factory method to create StoreModel from Firebase document snapshot
  factory BundleModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BundleModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      discount: data['discount'] ?? 0,
      items: (data['items'] as List<dynamic>?)
              ?.map((item) => {
                    'batchId': item['batchId'] as String,
                    'quantity': (item['quantity'] as num).toInt(),
                    'quantifier': item['quantifier'] as String,
                  })
              .toList() ??
          [],
      mainImageUrl: data['mainImageUrl'] ?? '',
      additionalImageUrls: (data['additionalImageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      category: data['category'] ?? '',
    );
  }

}

class BundleItem {
  final int quantity;
  final String productId;
  final String batchNumber;
  final String? productName;

  BundleItem({
    required this.productId,
    required this.batchNumber,
    required this.quantity,
    this.productName,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'batchNumber': batchNumber,
      'quantity': quantity,
    };
  }

  factory BundleItem.fromMap(Map<String, dynamic> map) {
    return BundleItem(
      productId: map['productId'],
      batchNumber: map['batchNumber'],
      quantity: map['quantity'],
      productName: map['productName'] ?? '',
    );
  }
}
