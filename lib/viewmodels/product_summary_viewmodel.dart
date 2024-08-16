import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/models/product_model.dart';

class ProductSummaryViewModel extends ChangeNotifier {
  ProductModel? _product;
  ProductModel? get product => _product;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchProductData(String productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (doc.exists) {
        _product = ProductModel.fromSnapshot(doc);
      }
    } catch (e) {
      // Handle errors
      print("Error fetching product data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
