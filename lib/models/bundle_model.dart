import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/models/product_model.dart';
import 'package:unshelf_seller/models/item_model.dart';

class BundleModel extends ItemModel {
  String description;
  double? price;
  int? stock;
  int? discount;
  List<String>? additionalImageUrls;
  List<Map<String, dynamic>> items;
  List<ProductModel>? products;

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

  // Factory method to create StoreModel from Firebase document snapshot
  factory BundleModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BundleModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      stock: (data['stock'] ?? 0 as num).toInt(),
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

  // factory BundleModel.fromJson(Map<String, dynamic> json) {
  //   List<BundleItem> bundleItems = json['products'] != null
  //       ? (json['products'] as List)
  //           .map((item) => BundleItem.fromMap(item))
  //           .toList()
  //       : [];

  //   List<String> productIdList =
  //       bundleItems.map((product) => product.productId).toList();

  //   return BundleModel(
  //     id: '',
  //     name: json['bundle_name'] ?? '',
  //     description: json['description'] ?? '',
  //     products: bundleItems,
  //     productIds: productIdList,
  //     category: '',
  //     price: 0.0,
  //     stock: 0,
  //     discount: 0,
  //     mainImageUrl: '',
  //   );
  // }
}

class BundleItem {
  final int quantity;
  final String productId;
  final String batchNumber;
  String? productName;

  BundleItem({
    required this.productId,
    required this.batchNumber,
    required this.quantity,
    this.productName,
  });

  factory BundleItem.fromMap(Map<String, dynamic> map) {
    return BundleItem(
      productId: map['productId'],
      batchNumber: map['batchNumber'],
      quantity: map['quantity'],
      productName: map['productName'] ?? '',
    );
  }
}
