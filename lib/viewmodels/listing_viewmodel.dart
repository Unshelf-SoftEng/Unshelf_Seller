import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unshelf_seller/models/bundle_model.dart';
import 'package:unshelf_seller/models/product_model.dart';
import 'package:unshelf_seller/models/item_model.dart';
import 'package:unshelf_seller/core/base_viewmodel.dart';
import 'package:unshelf_seller/core/logger.dart';
import 'package:unshelf_seller/core/constants/firestore_constants.dart';

class ListingViewModel extends BaseViewModel {
  List<ItemModel> _items = [];
  List<dynamic> _filteredItems = [];
  bool _showingProducts = true;
  List<ItemModel> get items => _items;
  bool get showingProducts => _showingProducts;
  String _searchQuery = '';
  List<dynamic> get filteredItems => _filteredItems;
  String _filter = 'All';
  String get filter => _filter;

  ListingViewModel() {
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

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final productSnapshot = await FirebaseFirestore.instance
            .collection(FirestoreConstants.products)
            .where('sellerId', isEqualTo: user.uid)
            .get();

        final products = productSnapshot.docs
            .map((doc) {
              try {
                return ProductModel.fromSnapshot(doc) as ItemModel?;
              } catch (e) {
                AppLogger.error('Error mapping product: $e');
                return null;
              }
            })
            .where((product) => product != null)
            .toList();

        final bundleSnapshot = await FirebaseFirestore.instance
            .collection(FirestoreConstants.bundles)
            .where('sellerId', isEqualTo: user.uid)
            .get();

        final bundles = bundleSnapshot.docs
            .map((doc) {
              try {
                return BundleModel.fromSnapshot(doc) as ItemModel?;
              } catch (e) {
                AppLogger.error('Error mapping bundle: $e');
                return null;
              }
            })
            .where((bundle) => bundle != null)
            .toList();

        _items = [
          ...products.whereType<ItemModel>(),
          ...bundles.whereType<ItemModel>()
        ];

        _filteredItems = _items;
      } catch (e) {
        AppLogger.error('Error fetching items: $e');
        _items = [];
      } finally {
        setLoading(false);
      }
    } else {
      _items = [];
      setLoading(false);
    }
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    await FirebaseFirestore.instance
        .collection(FirestoreConstants.products)
        .add(productData);
    fetchItems();
  }

  Future<void> addBundle(Map<String, dynamic> bundleData) async {
    await FirebaseFirestore.instance
        .collection(FirestoreConstants.bundles)
        .add(bundleData);
    fetchItems();
  }

  Future<void> deleteItem(String itemId, bool isProduct) async {
    final collection =
        isProduct ? FirestoreConstants.products : FirestoreConstants.bundles;
    await FirebaseFirestore.instance
        .collection(collection)
        .doc(itemId)
        .delete();

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
