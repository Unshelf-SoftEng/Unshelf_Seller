import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/models/product_model.dart';
import 'package:unshelf_seller/models/bundle_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RestockViewModel extends ChangeNotifier {
  List<ProductModel> _products = [];
  List<ProductModel> _selectedProducts = [];
  List<BundleModel> _bundles = [];
  List<BundleModel> _selectedBundles = [];

  bool _isLoading = false;

  String _error = '';

  List<ProductModel> get products => _products;
  List<ProductModel> get selectedProducts => _selectedProducts;
  List<BundleModel> get bundles => _bundles;
  List<BundleModel> get selectedBundles => _selectedBundles;

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

      _bundles =
          snapshot.docs.map((doc) => BundleModel.fromSnapshot(doc)).toList();
    } catch (e) {
      _error = 'Failed to fetch products: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addSelectedProduct(ProductModel product) {
    if (contain(product)) {
      return;
    }

    var addedProduct = ProductModel(
      productId: product.productId,
      name: product.name,
      price: product.price,
      stock: 0,
      expiryDate: null,
      description: product.description,
      category: product.category,
      quantifier: product.quantifier,
      discount: product.discount,
      mainImageUrl: product.mainImageUrl,
      additionalImageUrls: product.additionalImageUrls,
    );

    _selectedProducts.add(addedProduct);
    notifyListeners();
  }

  bool contain(ProductModel product) {
    for (var prod in _selectedProducts) {
      if (product.productId == prod.productId) {
        return true;
      }
    }

    return false;
  }

  void removeSelectedProduct(ProductModel product) {
    _selectedProducts.removeWhere((p) => p.productId == product.productId);
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

        // Retrieve the current stock
        final snapshot = await docRef.get();
        final currentQuantity = snapshot.data()?['stock'] ?? 0;

        // Add the new stock to the existing quantity
        final newQuantity = currentQuantity + product.stock;

        batch.update(docRef, {'stock': newQuantity});
      }
      await batch.commit();
      await fetchProducts();
      _selectedBundles.clear();
      _selectedProducts.clear();
    } catch (e) {
      _error = 'Failed to restock products: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateExpiryDate(ProductModel product, DateTime newDate) {
    product.expiryDate = newDate;
    notifyListeners(); // This will notify the UI to update
  }
}
