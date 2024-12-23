import 'package:flutter/material.dart';
import 'package:unshelf_seller/services/batch_service.dart';
import 'package:unshelf_seller/models/batch_model.dart';
import 'package:unshelf_seller/services/product_service.dart';

class SelectProductsViewModel extends ChangeNotifier {
  Map<String, BatchModel> _selectedItems = {};
  Map<String, BatchModel> get selectedItems => _selectedItems;

  List<BatchModel> _items = [];
  List<BatchModel> get items => _items;

  final BatchService batchService = BatchService();
  final ProductService productService = ProductService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _sortBy = 'expiryDate';
  String get sortBy => _sortBy;

  Future<void> fetchAllBatches() async {
    _isLoading = true;
    notifyListeners();

    _items = await batchService.getAllBatches();

    final List<Future<void>> productFutures = _items.map((item) async {
      if (item.productId != null) {
        item.product = await productService.getProduct(item.productId);
      } else {
        return item;
      }
    }).toList();

    await Future.wait(productFutures);

    _items.removeWhere((item) => item.product == null);

    _filteredItems = _items;
    _isLoading = false;

    notifyListeners();
  }

  // Method to add a product to the bundle
  void addProductToBundle(String batchNumber) {
    if (!_selectedItems.keys.contains(batchNumber)) {
      _selectedItems[batchNumber] =
          _items.firstWhere((product) => product.batchNumber == batchNumber);
      notifyListeners();
    }
  }

  // Method to remove a product from the bundle
  void removeProductFromBundle(String batchNumber) {
    _selectedItems.remove(batchNumber);
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

  void sortItems(String sortBy) {
    if (sortBy == 'name') {
      _sortBy = 'name';
      filteredItems.sort((a, b) => a.product!.name.compareTo(b.product!.name));
    } else if (sortBy == 'expiryDate') {
      _sortBy = 'expiryDate';
      filteredItems.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    }
    notifyListeners();
  }

  void _filterItems() {
    if (_searchQuery.isEmpty) {
      _filteredItems = _items;
    } else {
      print("Filtering items");

      _filteredItems = _items.where((item) {
        final name = item.product?.name.toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name!.contains(query);
      }).toList();

      print(_filteredItems);
    }
  }

  void clearSelection() {
    _selectedItems = {};
    notifyListeners();
  }
}
