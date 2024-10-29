import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unshelf_seller/models/bundle_model.dart';

class BundleService extends ChangeNotifier {
  Future<BundleModel?> getBundle(String bundleId) async {
    final productDoc = await FirebaseFirestore.instance
        .collection('products')
        .doc(bundleId)
        .get();

    if (productDoc.exists) {
      return BundleModel.fromSnapshot(productDoc);
    }

    return null;
  }

  Future<void> addProduct(BundleModel product) async {
    User? user = FirebaseAuth.instance.currentUser;

    try {
      await FirebaseFirestore.instance.collection('bundles').add({
        'name': product.name,
        'description': product.description,
        'category': product.category,
        'mainImageUrl': product.mainImageUrl,
        'additionalImageUrls': product.additionalImageUrls,
        'sellerId': user!.uid,
      });
    } catch (e) {
      print('Error adding product to Firestore: $e');
      rethrow;
    }
  }
}
