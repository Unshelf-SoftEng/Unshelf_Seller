import 'package:unshelf_seller/core/base_viewmodel.dart';
import 'package:unshelf_seller/core/interfaces/i_analytics_service.dart';
import 'package:unshelf_seller/core/interfaces/i_batch_service.dart';
import 'package:unshelf_seller/core/interfaces/i_product_service.dart';
import 'package:unshelf_seller/core/logger.dart';
import 'package:unshelf_seller/core/constants/status_constants.dart';
import 'package:unshelf_seller/models/product_model.dart';

class ProductAnalyticsViewModel extends BaseViewModel {
  final IProductService _productService;
  final IAnalyticsService _analyticsService;
  final IBatchService _batchService;

  ProductAnalyticsViewModel({
    required IProductService productService,
    required IAnalyticsService analyticsService,
    required IBatchService batchService,
  })  : _productService = productService,
        _analyticsService = analyticsService,
        _batchService = batchService;

  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;

  List<Map<String, dynamic>> topProducts = [];

  Future<void> fetchProductAnalytics() async {
    setLoading(true);
    // Fetch products from the service
    _products = await _productService.getProducts();

    setLoading(false);
  }

  Future<void> getTopProducts() async {
    setLoading(true);
    // Clear any existing data
    topProducts.clear();

    // Fetch all completed orders from the last 14 days
    final orderDocs = await _analyticsService.fetchOrders(
      since: DateTime.now().subtract(const Duration(days: 13)),
    );

    Map<String, int> batchCountMap = {};

    for (var orderDoc in orderDocs) {
      final data = orderDoc.data() as Map<String, dynamic>;

      // Filter by completed status
      if (data['status'] != StatusConstants.completed) continue;

      final orderItems = data['orderItems'] as List<dynamic>? ?? [];
      AppLogger.debug('Order items: $orderItems');

      for (var item in orderItems) {
        final String batchId = item['batchId'] as String? ?? '';
        final int quantity = (item['quantity'] as num?)?.toInt() ?? 0;

        if (batchId.isNotEmpty) {
          batchCountMap[batchId] = (batchCountMap[batchId] ?? 0) + quantity;
        }
      }
    }

    Map<String, int> productEntries = {};

    for (final entry in batchCountMap.entries) {
      final batch = await _batchService.getBatchById(entry.key);
      if (batch != null) {
        final productId = batch.productId;
        productEntries[productId] =
            (productEntries[productId] ?? 0) + entry.value;
      }
    }

    var sortedEntries = productEntries.entries.toList()
      ..sort((a, b) =>
          b.value.compareTo(a.value)); // Sort by value in descending order

    final top5 = sortedEntries.take(5).toList();

    for (var entry in top5) {
      final product = await _productService.getProduct(entry.key);
      if (product != null) {
        topProducts.add({
          'productId': product.id,
          'name': product.name,
          'quantity': entry.value,
        });
      }
    }

    setLoading(false);
  }
}
