import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unshelf_seller/models/product_model.dart';
import 'package:unshelf_seller/models/batch_model.dart';

class ProductService extends ChangeNotifier {
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

  Future<List<ProductModel>> getProducts() async {
    User? user = FirebaseAuth.instance.currentUser;

    final productDocs = await FirebaseFirestore.instance
        .collection('products')
        .where('sellerId', isEqualTo: user!.uid)
        .get();

    if (productDocs.docs.isNotEmpty) {
      return productDocs.docs
          .map((doc) => ProductModel.fromSnapshot(doc))
          .toList();
    }

    return [];
  }

  Future<List<BatchModel>?> getProductBatches(ProductModel product) async {
    final batchDocs = await FirebaseFirestore.instance
        .collection('batches')
        .where('productId', isEqualTo: product.id)
        .get();

    if (batchDocs.docs.isNotEmpty) {
      return batchDocs.docs
          .map((doc) => BatchModel.fromSnapshot(doc, product))
          .toList();
    }

    return null;
  }

  Future<String> addProduct(ProductModel product) async {
    User? user = FirebaseAuth.instance.currentUser;

    try {
      // Add the document and get the reference
      DocumentReference docRef =
          await FirebaseFirestore.instance.collection('products').add({
        'name': product.name,
        'description': product.description,
        'category': product.category,
        'mainImageUrl': product.mainImageUrl,
        'additionalImageUrls': product.additionalImageUrls,
        'sellerId': user!.uid,
      });

      // Return the document ID
      return docRef.id;
    } catch (e) {
      print('Error adding product to Firestore: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(String productId, ProductModel product) async {}
}
