import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unshelf_seller/models/product_model.dart';

class ProductService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<ProductModel?> getProduct(String productId) async {
    final productDoc = await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .get();

    if (productDoc.exists) {
      return ProductModel.fromSnapshot(productDoc);
    }

    return null;
  }

  Future<void> addProduct(ProductModel product) async {
    try {
      await FirebaseFirestore.instance.collection('products').add({
        'name': product.name,
        'description': product.description,
        'category': product.category,
        'mainImageUrl': product.mainImageUrl,
        'additionalImageUrls': product.additionalImageUrls,
      });
    } catch (e) {
      print('Error adding product to Firestore: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(String productId, ProductModel product) async {}
}
