import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:unshelf_seller/core/constants/firestore_constants.dart';
import 'package:unshelf_seller/core/current_user_provider.dart';
import 'package:unshelf_seller/core/errors/app_exceptions.dart';
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
    try {
      final productDoc = await _firestore
          .collection(FirestoreConstants.products)
          .doc(productId)
          .get();

      if (productDoc.exists) {
        return ProductModel.fromSnapshot(productDoc);
      }

      return null;
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to fetch product', e, stackTrace);
      throw FirestoreException('Failed to fetch product', originalError: e);
    }
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
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
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to fetch products', e, stackTrace);
      throw FirestoreException('Failed to fetch products', originalError: e);
    }
  }

  @override
  Future<List<BatchModel>?> getProductBatches(ProductModel product) async {
    try {
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
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to fetch product batches', e, stackTrace);
      throw FirestoreException('Failed to fetch product batches',
          originalError: e);
    }
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
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to add product', e, stackTrace);
      throw FirestoreException('Failed to add product', originalError: e);
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
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to update product', e, stackTrace);
      throw FirestoreException('Failed to update product', originalError: e);
    }
  }
}
