import 'package:flutter/material.dart';
import 'package:unshelf_seller/services/product_service.dart';
import 'package:unshelf_seller/models/product_model.dart';

class ProductAnalyticsViewModel extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchProductAnalytics() async {
    _isLoading = true;
    notifyListeners();

    // Fetch products from the service
    _products = await _productService.getProducts();

    _isLoading = false;
    notifyListeners();
  }
}
