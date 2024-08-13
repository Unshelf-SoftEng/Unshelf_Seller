import 'package:flutter/foundation.dart';
import 'package:unshelf_seller/models/bundle_model.dart';

class BundleViewModel extends ChangeNotifier {
  List<BundleModel> _bundles = [];
  BundleModel? _selectedBundle;
  String _newBundleName = '';
  List<String> _selectedProductIds = [];

  List<BundleModel> get bundles => _bundles;
  BundleModel? get selectedBundle => _selectedBundle;
  String get newBundleName => _newBundleName;
  List<String> get selectedProductIds => _selectedProductIds;

  void setNewBundleName(String name) {
    _newBundleName = name;
    notifyListeners();
  }

  void addProductToBundle(String productId) {
    if (!_selectedProductIds.contains(productId)) {
      _selectedProductIds.add(productId);
      notifyListeners();
    }
  }

  void removeProductFromBundle(String productId) {
    _selectedProductIds.remove(productId);
    notifyListeners();
  }

  void createBundle() {
    if (_newBundleName.isNotEmpty && _selectedProductIds.isNotEmpty) {
      final newBundle = BundleModel(
        bundleId: DateTime.now().toString(), // Generate a unique ID
        name: _newBundleName,
        price: 0.0,
        productIds: _selectedProductIds,
        mainImageUrl: '',
      );
      _bundles.add(newBundle);
      _newBundleName = '';
      _selectedProductIds = [];
      notifyListeners();
    }
  }
}
