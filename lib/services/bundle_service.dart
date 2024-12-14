import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unshelf_seller/models/bundle_model.dart';

class BundleService extends ChangeNotifier {
  Future<BundleModel?> getBundle(String bundleId) async {
    final productDoc = await FirebaseFirestore.instance
        .collection('bundles')
        .doc(bundleId)
        .get();

    if (productDoc.exists) {
      return BundleModel.fromSnapshot(productDoc);
    }

    return null;
  }

  Future<void> createBundle(BundleModel bundle) async {
    User user = FirebaseAuth.instance.currentUser!;

    try {
      final bundleData = {
        'name': bundle.name,
        'category': bundle.category,
        'description': bundle.description,
        'items': bundle.items,
        'price': bundle.price,
        'stock': bundle.stock,
        'discount': bundle.discount,
        'mainImageUrl': bundle.mainImageUrl,
        'sellerId': user.uid,
        'isListed': true,
      };

      await FirebaseFirestore.instance.collection('bundles').add(bundleData);
    } catch (e) {
      print('Error adding product to Firestore: $e');
      rethrow;
    }
  }

  Future<void> updateBundle(BundleModel bundle) async {
    try {
      final bundleData = {
        'name': bundle.name,
        'category': bundle.category,
        'description': bundle.description,
        'items': bundle.items,
        'price': bundle.price,
        'stock': bundle.stock,
        'discount': bundle.discount,
        'mainImageUrl': bundle.mainImageUrl,
      };

      await FirebaseFirestore.instance
          .collection('bundles')
          .doc(bundle.id)
          .update(bundleData);
    } catch (e) {
      print('Error updating product in Firestore: $e');
      rethrow;
    }
  }
}
