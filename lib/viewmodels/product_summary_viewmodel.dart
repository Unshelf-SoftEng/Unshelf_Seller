import 'package:flutter/material.dart';
import 'package:unshelf_seller/models/product_model.dart';
import 'package:unshelf_seller/services/product_service.dart';

class ProductSummaryViewModel extends ChangeNotifier {
  final ProductService _productService = ProductService();
  ProductModel? _product;
  ProductModel? get product => _product;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchProductData(String productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final product = await _productService.getProduct(productId);

      if (product != null) {
        _product = product;
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
