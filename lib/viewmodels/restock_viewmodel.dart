import 'package:unshelf_seller/models/bundle_model.dart';
import 'package:unshelf_seller/models/batch_model.dart';
import 'package:unshelf_seller/core/base_viewmodel.dart';
import 'package:unshelf_seller/core/interfaces/i_product_service.dart';
import 'package:unshelf_seller/core/logger.dart';

class RestockViewModel extends BaseViewModel {
  final IProductService _productService;

  List<BatchModel> _products = [];
  final List<BatchModel> _selectedProducts = [];
  final List<BundleModel> _bundles = [];
  final List<BundleModel> _selectedBundles = [];

  String _error = '';

  List<BatchModel> get products => _products;
  List<BatchModel> get selectedProducts => _selectedProducts;
  List<BundleModel> get bundles => _bundles;
  List<BundleModel> get selectedBundles => _selectedBundles;

  String get error => _error;

  RestockViewModel({required IProductService productService})
      : _productService = productService;

  Future<void> fetchProducts() async {
    setLoading(true);

    try {
      final allProducts = await _productService.getProducts();

      final List<BatchModel> batches = [];
      for (final product in allProducts) {
        final productBatches = await _productService.getProductBatches(product);
        if (productBatches != null) {
          batches.addAll(productBatches);
        }
      }

      _products = batches;
    } catch (e) {
      AppLogger.error('Failed to fetch products for restock', e);
      _error = 'Failed to fetch products: $e';
    } finally {
      setLoading(false);
    }
  }

  void addSelectedProduct(BatchModel product) {
    if (contain(product)) {
      return;
    }
    _selectedProducts.add(product);
    notifyListeners();
  }

  bool contain(BatchModel product) {
    for (var selected in _selectedProducts) {
      if (product.batchNumber == selected.batchNumber) {
        return true;
      }
    }

    return false;
  }

  void removeSelectedProduct(BatchModel product) {
    _selectedProducts.removeWhere((p) => p.batchNumber == product.batchNumber);
    notifyListeners();
  }

  Future<void> batchRestock(List<BatchModel> productsToRestock) async {
    setLoading(true);

    try {
      // Batch restock logic placeholder - implement when batch update service
      // method is available
    } catch (e) {
      _error = 'Failed to restock products: $e';
    } finally {
      setLoading(false);
    }
  }

  void updateExpiryDate(BatchModel product, DateTime newDate) {
    product.expiryDate = newDate;
    notifyListeners();
  }
}
