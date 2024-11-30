import 'package:flutter/material.dart';
import 'package:unshelf_seller/services/batch_service.dart';
import 'package:unshelf_seller/models/batch_model.dart';
import 'package:unshelf_seller/services/product_service.dart';

class SelectProductsViewModel extends ChangeNotifier {
  Map<String, BatchModel> _selectedProducts = {};
  Map<String, BatchModel> get selectedProducts => _selectedProducts;

  List<BatchModel> _products = [];
  List<BatchModel> get products => _products;

  final BatchService batchService = BatchService();
  final ProductService productService = ProductService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    _products = await batchService.getAllBatches();
    for (var product in _products) {
      product.product = await productService.getProduct(product.productId);
    }
    _filteredItems = _products;
    _isLoading = false;
    notifyListeners();
  }

  // Method to add a product to the bundle
  void addProductToBundle(String productId) {
    if (!_selectedProducts.keys.contains(productId)) {
      _selectedProducts[productId] =
          _products.firstWhere((product) => product.batchNumber == productId);
      notifyListeners();
    }
  }

  // Method to remove a product from the bundle
  void removeProductFromBundle(String productId) {
    _selectedProducts.remove(productId);
    notifyListeners();
  }

  String _searchQuery = '';
  List<BatchModel> get filteredItems => _filteredItems;
  List<BatchModel> _filteredItems = [];

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _filterItems();
    notifyListeners();
  }

  void _filterItems() {
    if (_searchQuery.isEmpty) {
      _filteredItems = _products;
    } else {
      print("Filtering items");

      _filteredItems = _products.where((item) {
        print(item.product?.name);

        final name = item.product?.name.toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name!.contains(query);
      }).toList();

      print(_filteredItems);
    }
  }

  void clearSelection() {
    _selectedProducts = {};
    notifyListeners();
  }
}
