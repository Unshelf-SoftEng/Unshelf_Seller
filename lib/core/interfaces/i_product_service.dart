import 'package:unshelf_seller/models/batch_model.dart';
import 'package:unshelf_seller/models/product_model.dart';

abstract class IProductService {
  Future<ProductModel?> getProduct(String productId);
  Future<List<ProductModel>> getProducts();
  Future<List<BatchModel>?> getProductBatches(ProductModel product);
  Future<String> addProduct(ProductModel product);
  Future<void> updateProduct(String productId, ProductModel product);
}
