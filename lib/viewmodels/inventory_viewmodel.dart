import 'package:unshelf_seller/core/base_viewmodel.dart';
import 'package:unshelf_seller/core/interfaces/i_batch_service.dart';
import 'package:unshelf_seller/core/interfaces/i_product_service.dart';
import 'package:unshelf_seller/core/logger.dart';
import 'package:unshelf_seller/models/inventory_product_model.dart';

class InventoryViewModel extends BaseViewModel {
  final IProductService _productService;
  final IBatchService _batchService;

  InventoryViewModel({
    required IProductService productService,
    required IBatchService batchService,
  })  : _productService = productService,
        _batchService = batchService;

  List<InventoryProductModel> _inventoryItems = [];
  List<InventoryProductModel> get inventoryItems => _inventoryItems;

  Future<void> fetchInventory() async {
    await runBusyFuture(() async {
      var products = await _productService.getProducts();

      for (var product in products) {
        var batches = await _batchService.getBatchesByProductId(product.id);

        _inventoryItems.add(InventoryProductModel(
          id: product.id,
          name: product.name,
          mainImageUrl: product.mainImageUrl,
          batches: batches,
        ));
      }

      AppLogger.debug('Inventory fetched successfully');
    });
  }

  void clearData() {
    _inventoryItems = [];
    notifyListeners();
  }
}
