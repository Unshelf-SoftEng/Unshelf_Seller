import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/models/item_model.dart';

class ProductModel implements ItemModel {
  @override
  String get id => productId;
  final String productId;
  String name;
  String description;
  String category;
  double price;
  String quantifier;
  int? stock;
  DateTime? expiryDate;
  int discount;
  String mainImageUrl;
  List<String>? additionalImageUrls;

  ProductModel({
    required this.productId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.quantifier,
    required this.discount,
    required this.mainImageUrl,
    this.stock,
    this.expiryDate,
    this.additionalImageUrls,
  });

  // Factory method to create StoreModel from Firebase document snapshot
  factory ProductModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      productId: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      quantifier: data['quantifier'] ?? '',
      stock: data['stock'] ?? 0,
      expiryDate: data['expiryDate'] != null
          ? (data['expiryDate'] as Timestamp).toDate()
          : DateTime.now(),
      discount: data['discount'] ?? 0,
      mainImageUrl: data['mainImageUrl'] ?? '',
      additionalImageUrls: (data['additionalImageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  // Method to convert StoreModel to Json
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'expiryDate': expiryDate!.toIso8601String(),
      'discount': discount,
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      price: json['price'] ?? 0.0,
      quantifier: json['quantifier'] ?? '',
      stock: json['stock'] ?? 0,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : DateTime.now(),
      discount: json['discount'] ?? 0,
      mainImageUrl: json['mainImageUrl'] ?? '',
    );
  }
}
