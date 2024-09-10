import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/models/product_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RestockViewModel extends ChangeNotifier {
  List<ProductModel> _products = [];
  List<ProductModel> _selectedProducts = []; // For the second screen
  bool _isLoading = false;
  String _error = '';

  List<ProductModel> get products => _products;
  List<ProductModel> get selectedProducts => _selectedProducts;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _error = 'No user is logged in.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final sellerId = currentUser.uid;

      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .get();

      _products =
          snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
    } catch (e) {
      _error = 'Failed to fetch products: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addSelectedProduct(ProductModel product) {
    _selectedProducts.add(product);
    notifyListeners();
  }

  void removeSelectedProduct(ProductModel product) {
    _selectedProducts.remove(product);
    notifyListeners();
  }

  Future<void> batchRestock(List<ProductModel> productsToRestock) async {
    _isLoading = true;
    notifyListeners();

    try {
      final batch = FirebaseFirestore.instance.batch();
      for (var product in productsToRestock) {
        final docRef = FirebaseFirestore.instance
            .collection('products')
            .doc(product.productId);
        batch.update(docRef, {'quantity': product.stock});
      }
      await batch.commit();
    } catch (e) {
      _error = 'Failed to restock products: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
