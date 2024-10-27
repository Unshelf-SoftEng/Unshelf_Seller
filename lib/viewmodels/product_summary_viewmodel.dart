import 'package:flutter/material.dart';
import 'package:unshelf_seller/models/batch_model.dart';
import 'package:unshelf_seller/models/product_model.dart';
import 'package:unshelf_seller/services/product_service.dart';

class ProductSummaryViewModel extends ChangeNotifier {
  final ProductService _productService = ProductService();
  ProductModel? _product;
  ProductModel? get product => _product;
  List<BatchModel>? _batches;
  List<BatchModel>? get batches => _batches;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  PageController _pageController = PageController();
  PageController get pageController => _pageController;
  int _currentPage = 0;
  int get currentPage => _currentPage;

  Future<void> fetchProductData(String productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _product = await _productService.getProduct(productId);
      _batches = await _productService.getProductBatches(product!);
    } catch (e) {
      // Handle errors
      print("Error fetching product data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onPageChanged(int index) {
    _currentPage = index;
    notifyListeners();
  }
}
