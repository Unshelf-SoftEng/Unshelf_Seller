import 'package:flutter/material.dart';
import 'package:unshelf_seller/services/batch_service.dart';
import 'package:unshelf_seller/models/batch_model.dart';
import 'package:unshelf_seller/services/product_service.dart';

class SelectProductsViewModel extends ChangeNotifier {
  List<BatchModel> _products = [];
  List<String> _selectedProductIds = [];

  List<BatchModel> get products => _products;
  List<String> get selectedProductIds => _selectedProductIds;

  final BatchService batchService = BatchService();
  final ProductService productService = ProductService();

  Future<void> fetchProducts() async {
    print('Fetching bundless');
    _products = await batchService.getAllBatches();

    print('Fetched ${_products.length} batches');

    for (var product in _products) {
      print(
          'Fetching product: ${product.productId} for batch: ${product.batchNumber}');

      product.product = await productService.getProduct(product.productId);

      print('Product: ${product.product!.name}');
    }

    notifyListeners();
  }

  // Method to add a product to the bundle
  void addProductToBundle(String productId) {
    if (!_selectedProductIds.contains(productId)) {
      _selectedProductIds.add(productId);
      notifyListeners(); // Notify listeners to update the UI
    }
  }

  // Method to remove a product from the bundle
  void removeProductFromBundle(String productId) {
    _selectedProductIds.remove(productId);
    notifyListeners(); // Notify listeners to update the UI
  }
}
