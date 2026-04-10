import 'package:unshelf_seller/core/base_viewmodel.dart';
import 'package:unshelf_seller/core/interfaces/i_batch_service.dart';
import 'package:unshelf_seller/core/interfaces/i_product_service.dart';
import 'package:unshelf_seller/core/logger.dart';
import 'package:unshelf_seller/models/batch_model.dart';

class SelectProductsViewModel extends BaseViewModel {
  final IBatchService _batchService;
  final IProductService _productService;

  SelectProductsViewModel({
    required IBatchService batchService,
    required IProductService productService,
  })  : _batchService = batchService,
        _productService = productService;

  Map<String, BatchModel> _selectedItems = {};
  Map<String, BatchModel> get selectedItems => _selectedItems;

  List<BatchModel> _items = [];
  List<BatchModel> get items => _items;

  String _sortBy = 'expiryDate';
  String get sortBy => _sortBy;

  String _searchQuery = '';
  List<BatchModel> get filteredItems => _filteredItems;
  List<BatchModel> _filteredItems = [];

  Future<void> fetchAllBatches() async {
    setLoading(true);
    notifyListeners();

    _items = await _batchService.getAllBatches();

    final List<Future<void>> productFutures = _items.map((item) async {
      item.product = await _productService.getProduct(item.productId);
    }).toList();

    await Future.wait(productFutures);

    _items.removeWhere((item) => item.product == null);

    _filteredItems = _items;
    setLoading(false);

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
      AppLogger.debug('Filtering items');

      _filteredItems = _items.where((item) {
        final name = item.product?.name.toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name!.contains(query);
      }).toList();

      AppLogger.debug('Filtered items: $_filteredItems');
    }
  }

  void clearSelection() {
    _selectedItems = {};
    notifyListeners();
  }
}
