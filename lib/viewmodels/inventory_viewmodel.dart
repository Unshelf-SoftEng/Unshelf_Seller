import 'package:flutter/material.dart';
import 'package:unshelf_seller/models/inventory_product_model.dart';
import 'package:unshelf_seller/services/product_service.dart';
import 'package:unshelf_seller/services/batch_service.dart';

class InventoryViewModel extends ChangeNotifier {
  List<InventoryProductModel> _inventoryItems = [];
  bool _isLoading = false;

  List<InventoryProductModel> get inventoryItems => _inventoryItems;
  bool get isLoading => _isLoading;

  Future<void> fetchInventory() async {
    _isLoading = true;
    notifyListeners();

    try {
      var products = await ProductService().getProducts();

      for (var product in products) {
        var batches = await BatchService().getBatchesByProductId(product.id);

        _inventoryItems.add(InventoryProductModel(
          id: product.id,
          name: product.name,
          mainImageUrl: product.mainImageUrl,
          batches: batches,
        ));
      }

      print('Inventory fetched successfully');
    } catch (e) {
      print('Error fetching inventory: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearData() {
    _inventoryItems = [];
    notifyListeners();
  }
}
