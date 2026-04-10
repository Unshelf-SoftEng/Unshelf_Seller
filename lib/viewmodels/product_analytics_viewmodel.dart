import 'package:unshelf_seller/core/base_viewmodel.dart';
import 'package:unshelf_seller/core/interfaces/i_product_service.dart';
import 'package:unshelf_seller/core/logger.dart';
import 'package:unshelf_seller/core/constants/firestore_constants.dart';
import 'package:unshelf_seller/core/constants/status_constants.dart';
import 'package:unshelf_seller/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductAnalyticsViewModel extends BaseViewModel {
  final IProductService _productService;

  ProductAnalyticsViewModel({required IProductService productService})
      : _productService = productService;

  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;

  List<Map<String, dynamic>> topProducts = [];

  User? user = FirebaseAuth.instance.currentUser;

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

    // Fetch all orders
    final QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
        .collection(FirestoreConstants.orders)
        .where('sellerId', isEqualTo: user!.uid)
        .where('status', isEqualTo: StatusConstants.completed)
        .where('createdAt',
            isGreaterThanOrEqualTo: DateTime.now().subtract(const Duration(days: 13)))
        .get();

    Map<String, int> batchCountMap = {};
    Map<String, int> bundleCountMap = {};

    for (var orderDoc in ordersSnapshot.docs) {
      var orderItems = orderDoc['orderItems'];
      AppLogger.debug('Order items: $orderItems');

      for (var item in orderItems) {
        String batchId = item['batchId'];
        String bundleId = item['bundleId'];
        int quantity = item['quantity'];

        batchCountMap[batchId] = (batchCountMap[batchId] ?? 0) + quantity;
        bundleCountMap[bundleId] = (bundleCountMap[bundleId] ?? 0) + quantity;
      }
    }

    Map<String, int> productEntries = {};

    for (final entry in batchCountMap.entries) {
      // Fetch batch details using the key
      DocumentSnapshot batchDoc = await FirebaseFirestore.instance
          .collection(FirestoreConstants.batches)
          .doc(entry.key) // Use 'key' to fetch the document
          .get();

      if (batchDoc.exists) {
        String productId = batchDoc['productId'];
        productEntries[productId] = (productEntries[productId] ?? 0) + entry.value;
      }
    }

    var sortedEntries = productEntries.entries.toList()
      ..sort((a, b) =>
          b.value.compareTo(a.value)); // Sort by value in descending order

    var top5 = sortedEntries.take(5).toList();

    for (var entry in top5) {
      // Fetch product details using the productId
      DocumentSnapshot productDoc = await FirebaseFirestore.instance
          .collection(FirestoreConstants.products)
          .doc(entry.key) // Use 'key' to fetch the document
          .get();

      if (productDoc.exists) {
        topProducts.add({
          'productId': productDoc.id,
          'name': productDoc['name'],
          'quantity': entry.value,
        });
      }
    }

    setLoading(false);
  }
}
