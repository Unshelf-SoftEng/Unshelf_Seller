import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:unshelf_seller/core/constants/firestore_constants.dart';
import 'package:unshelf_seller/core/current_user_provider.dart';
import 'package:unshelf_seller/core/interfaces/i_product_service.dart';
import 'package:unshelf_seller/core/logger.dart';
import 'package:unshelf_seller/models/batch_model.dart';
import 'package:unshelf_seller/models/product_model.dart';

class ProductService implements IProductService {
  final FirebaseFirestore _firestore;
  final CurrentUserProvider _currentUser;

  ProductService({
    FirebaseFirestore? firestore,
    CurrentUserProvider? currentUser,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _currentUser = currentUser ?? CurrentUserProvider();

  @override
  Future<ProductModel?> getProduct(String productId) async {
    final productDoc = await _firestore
        .collection(FirestoreConstants.products)
        .doc(productId)
        .get();

    if (productDoc.exists) {
      return ProductModel.fromSnapshot(productDoc);
    }

    return null;
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    final productDocs = await _firestore
        .collection(FirestoreConstants.products)
        .where(FirestoreConstants.sellerId, isEqualTo: _currentUser.uid)
        .get();

    if (productDocs.docs.isNotEmpty) {
      return productDocs.docs
          .map((doc) => ProductModel.fromSnapshot(doc))
          .toList();
    }

    return [];
  }

  @override
  Future<List<BatchModel>?> getProductBatches(ProductModel product) async {
    final batchDocs = await _firestore
        .collection(FirestoreConstants.batches)
        .where(FirestoreConstants.productId, isEqualTo: product.id)
        .get();

    if (batchDocs.docs.isNotEmpty) {
      return batchDocs.docs
          .map((doc) => BatchModel.fromSnapshot(doc, product))
          .toList();
    }

    return null;
  }

  @override
  Future<String> addProduct(ProductModel product) async {
    try {
      DocumentReference docRef =
          await _firestore.collection(FirestoreConstants.products).add({
        'name': product.name,
        'description': product.description,
        'category': product.category,
        'mainImageUrl': product.mainImageUrl,
        'additionalImageUrls': product.additionalImageUrls,
        FirestoreConstants.sellerId: _currentUser.uid,
      });

      return docRef.id;
    } catch (e, stackTrace) {
      AppLogger.error('Error adding product to Firestore', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> updateProduct(String productId, ProductModel product) async {
    try {
      await _firestore
          .collection(FirestoreConstants.products)
          .doc(productId)
          .update({
        'name': product.name,
        'description': product.description,
        'category': product.category,
        'mainImageUrl': product.mainImageUrl,
      });
    } catch (e, stackTrace) {
      AppLogger.error('Error updating product', e, stackTrace);
      rethrow;
    }
  }
}
