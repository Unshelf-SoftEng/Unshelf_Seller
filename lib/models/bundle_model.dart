import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/models/item_model.dart';
import 'package:unshelf_seller/models/product_model.dart';

class BundleModel extends ItemModel {
  List<String> productIds;
  double? price;
  int? stock;
  int? discount;
  List<String>? additionalImageUrls;
  List<ProductModel>? products;

  BundleModel(
      {required super.id,
      required super.name,
      required super.mainImageUrl,
      required super.category,
      required this.productIds,
      this.price,
      this.stock,
      this.discount,
      this.additionalImageUrls,
      this.products});

  // Factory method to create StoreModel from Firebase document snapshot
  factory BundleModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BundleModel(
        id: doc.id,
        name: data['name'] ?? '',
        price: (data['price'] ?? 0.0).toDouble(),
        stock: data['stock'] ?? 0,
        discount: data['discount'] ?? 0,
        productIds: (data['productIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        mainImageUrl: data['mainImageUrl'] ?? '',
        additionalImageUrls: (data['additionalImageUrls'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        category: data['category']);
  }

  factory BundleModel.fromJson(Map<String, dynamic> json) {
    List<ProductModel> productList = json['products'] != null
        ? (json['products'] as List)
            .map((product) => ProductModel.fromJson(product))
            .toList()
        : [];

    List<String> productIdList =
        productList.map((product) => product.id).toList();

    return BundleModel(
      id: '',
      name: json['bundle_name'] ?? '',
      products: productList,
      productIds: productIdList,
      category: '',
      price: 0.0,
      stock: 0,
      discount: 0,
      mainImageUrl: '',
    );
  }
}
