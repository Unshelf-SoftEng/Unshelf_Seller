import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/models/item_model.dart';

class ProductModel extends ItemModel {
  String description;
  List<String>? additionalImageUrls;

  ProductModel({
    required super.id,
    required super.name,
    required super.mainImageUrl,
    required super.category,
    required this.description,
    this.additionalImageUrls,
  });

  factory ProductModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      mainImageUrl: data['mainImageUrl'] ?? '',
      additionalImageUrls: (data['additionalImageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  // Method to convert StoreModel to Json
  Map<String, dynamic> toJson() {
    return {
      'productId': id,
      'name': name,
      'description': description,
      'category': category,
      'mainImageUrl': mainImageUrl,
      'additionalImageUrls': additionalImageUrls,
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      mainImageUrl: json['mainImageUrl'] ?? '',
      additionalImageUrls: (json['additionalImageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }
}
