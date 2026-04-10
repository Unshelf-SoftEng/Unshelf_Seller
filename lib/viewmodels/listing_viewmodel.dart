import 'package:unshelf_seller/models/bundle_model.dart';
import 'package:unshelf_seller/models/product_model.dart';
import 'package:unshelf_seller/models/item_model.dart';
import 'package:unshelf_seller/core/base_viewmodel.dart';
import 'package:unshelf_seller/core/interfaces/i_bundle_service.dart';
import 'package:unshelf_seller/core/interfaces/i_product_service.dart';
import 'package:unshelf_seller/core/logger.dart';

class ListingViewModel extends BaseViewModel {
  final IProductService _productService;
  final IBundleService _bundleService;

  List<ItemModel> _items = [];
  List<dynamic> _filteredItems = [];
  bool _showingProducts = true;
  List<ItemModel> get items => _items;
  bool get showingProducts => _showingProducts;
  String _searchQuery = '';
  List<dynamic> get filteredItems => _filteredItems;
  String _filter = 'All';
  String get filter => _filter;

  ListingViewModel({
    required IProductService productService,
    required IBundleService bundleService,
  })  : _productService = productService,
        _bundleService = bundleService {
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

    if (_filter == 'Bundles') {
      _filteredItems = _filteredItems.whereType<BundleModel>().toList();
    }

    if (_filter == 'Products') {
      _filteredItems = _filteredItems.whereType<ProductModel>().toList();
    }
  }

  void setFilter(String filter) {
    _filter = filter;
    _filterItems();
    notifyListeners();
  }

  Future<void> refreshItems() async {
    _filterItems();
  }

  Future<void> fetchItems() async {
    setLoading(true);

    try {
      final products = await _productService.getProducts();
      final bundles = await _bundleService.getBundles();

      _items = [
        ...products.cast<ItemModel>(),
        ...bundles.cast<ItemModel>(),
      ];

      _filteredItems = _items;
    } catch (e) {
      AppLogger.error('Error fetching items: $e');
      _items = [];
    } finally {
      setLoading(false);
    }
  }

  Future<void> addProduct(ProductModel product) async {
    await _productService.addProduct(product);
    fetchItems();
  }

  Future<void> addBundle(BundleModel bundle) async {
    await _bundleService.createBundle(bundle);
    fetchItems();
  }

  Future<void> deleteItem(String itemId, bool isProduct) async {
    if (isProduct) {
      await _productService.deleteProduct(itemId);
    } else {
      await _bundleService.deleteBundle(itemId);
    }

    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void toggleView() {
    _showingProducts = !_showingProducts;
    fetchItems();
  }

  void clear() {
    _items = [];
    setLoading(true);
  }
}
