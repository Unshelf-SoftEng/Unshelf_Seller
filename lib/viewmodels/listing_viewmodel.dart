// viewmodels/item_view_model.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unshelf_seller/models/bundle_model.dart';
import 'package:unshelf_seller/models/product_model.dart';
import 'package:unshelf_seller/models/item_model.dart';

class ListingViewModel extends ChangeNotifier {
  List<ItemModel> _items = [];
  List<dynamic> _filteredItems = [];
  bool _isLoading = true;
  bool _showingProducts = true;
  List<ItemModel> get items => _items;
  bool get isLoading => _isLoading;
  bool get showingProducts => _showingProducts;
  String _searchQuery = '';
  List<dynamic> get filteredItems => _filteredItems;

  ListingViewModel() {
    fetchItems();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _filterItems();
    notifyListeners();
  }

  void _filterItems() {
    if (_searchQuery.isEmpty) {
      _filteredItems = _items;
    } else {
      _filteredItems = _items.where((item) {
        final name = item.name.toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query);
      }).toList();
    }
  }

  Future<void> refreshItems() async {
    _filterItems();
  }

  Future<void> fetchItems() async {
    _isLoading = true;
    notifyListeners();

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Fetch products
        final productSnapshot = await FirebaseFirestore.instance
            .collection('products')
            .where('sellerId', isEqualTo: user.uid)
            .where('isListed', isEqualTo: true)
            .get();

        final products = productSnapshot.docs
            .map((doc) {
              try {
                return ProductModel.fromSnapshot(doc) as ItemModel?;
              } catch (e) {
                print('Error mapping product: $e');
                return null;
              }
            })
            .where((product) => product != null)
            .cast<ItemModel>()
            .toList();

        final bundleSnapshot = await FirebaseFirestore.instance
            .collection('bundles')
            .where('sellerId', isEqualTo: user.uid)
            .where('isListed', isEqualTo: true)
            .get();

        final bundles = bundleSnapshot.docs
            .map((doc) {
              try {
                return BundleModel.fromSnapshot(doc) as ItemModel?;
              } catch (e) {
                print('Error mapping bundle: $e');
                return null;
              }
            })
            .where((bundle) => bundle != null)
            .cast<ItemModel>()
            .toList();

        _items = showingProducts ? products : bundles;
        _filteredItems = _items;
      } catch (e) {
        print('Error fetching items: $e');
        _items = [];
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    } else {
      _items = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    await FirebaseFirestore.instance.collection('products').add(productData);
    fetchItems();
  }

  Future<void> addBundle(Map<String, dynamic> bundleData) async {
    await FirebaseFirestore.instance.collection('bundles').add(bundleData);
    fetchItems();
  }

  Future<void> deleteItem(String itemId, bool isProduct) async {
    final collection = isProduct ? 'products' : 'bundles';
    await FirebaseFirestore.instance
        .collection(collection)
        .doc(itemId)
        .delete();
    fetchItems();
  }

  void toggleView() {
    _showingProducts = !_showingProducts;
    fetchItems();
  }

  void clear() {
    _items = [];
    _isLoading = true;
    notifyListeners();
  }
}
