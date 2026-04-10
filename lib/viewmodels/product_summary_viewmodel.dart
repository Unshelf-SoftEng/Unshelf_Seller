import 'package:flutter/material.dart';

import 'package:unshelf_seller/core/base_viewmodel.dart';
import 'package:unshelf_seller/core/interfaces/i_batch_service.dart';
import 'package:unshelf_seller/core/interfaces/i_product_service.dart';
import 'package:unshelf_seller/core/logger.dart';
import 'package:unshelf_seller/models/batch_model.dart';
import 'package:unshelf_seller/models/product_model.dart';

class ProductSummaryViewModel extends BaseViewModel {
  final IProductService _productService;
  final IBatchService _batchService;

  ProductSummaryViewModel({
    required IProductService productService,
    required IBatchService batchService,
  })  : _productService = productService,
        _batchService = batchService;

  ProductModel? _product;
  ProductModel? get product => _product;
  List<BatchModel>? _batches;
  List<BatchModel>? get batches => _batches;

  final PageController _pageController = PageController();
  PageController get pageController => _pageController;
  int _currentPage = 0;
  int get currentPage => _currentPage;

  Future<void> fetchProductData(String productId) async {
    setLoading(true);
    notifyListeners();

    try {
      _product = await _productService.getProduct(productId);
      _batches = await _productService.getProductBatches(product!);
    } catch (e) {
      AppLogger.error('Error fetching product data: $e');
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  void onPageChanged(int index) {
    _currentPage = index;
    notifyListeners();
  }

  Future<void> deleteBatch(String batchNumber) async {
    await _batchService.deleteBatch(batchNumber);
    _batches!.removeWhere((batch) => batch.batchNumber == batchNumber);
    notifyListeners();
  }
}
