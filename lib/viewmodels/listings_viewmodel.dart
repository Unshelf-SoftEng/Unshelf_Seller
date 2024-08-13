// viewmodels/item_view_model.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unshelf_seller/models/bundle_model.dart';
import 'package:unshelf_seller/models/product_model.dart';
import 'package:unshelf_seller/models/item_model.dart';

class ListingViewModel extends ChangeNotifier {
  List<ItemModel> _items = [];
  bool _isLoading = true;
  bool _showingProducts = true;

  List<ItemModel> get items => _items;
  bool get isLoading => _isLoading;
  bool get showingProducts => _showingProducts;

  ListingViewModel() {
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    _isLoading = true;
    notifyListeners();

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Fetch products
      final productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('seller_id', isEqualTo: user.uid)
          .get();
      final products = productSnapshot.docs
          .map((doc) => ProductModel.fromSnapshot(doc))
          .toList();

      // Fetch bundles
      const bundles = null;

      _items = showingProducts ? products : bundles;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    await FirebaseFirestore.instance.collection('products').add(productData);
    _fetchItems(); // Refresh the list
  }

  Future<void> addBundle(Map<String, dynamic> bundleData) async {
    await FirebaseFirestore.instance.collection('bundles').add(bundleData);
    _fetchItems(); // Refresh the list
  }

  Future<void> deleteItem(String itemId, bool isProduct) async {
    final collection = isProduct ? 'products' : 'bundles';
    await FirebaseFirestore.instance
        .collection(collection)
        .doc(itemId)
        .delete();
    _fetchItems(); // Refresh the list
  }

  void toggleView() {
    _showingProducts = !_showingProducts;
    _fetchItems(); // Refresh the list based on the selected view
  }

  void refreshItems() {
    _fetchItems();
  }
}
