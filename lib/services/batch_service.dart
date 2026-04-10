import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';

import 'package:unshelf_seller/core/constants/firestore_constants.dart';
import 'package:unshelf_seller/core/current_user_provider.dart';
import 'package:unshelf_seller/core/interfaces/i_batch_service.dart';
import 'package:unshelf_seller/core/interfaces/i_product_service.dart';
import 'package:unshelf_seller/core/logger.dart';
import 'package:unshelf_seller/models/batch_model.dart';

class BatchService implements IBatchService {
  final FirebaseFirestore _firestore;
  final CurrentUserProvider _currentUser;
  final IProductService _productService;

  BatchService({
    FirebaseFirestore? firestore,
    CurrentUserProvider? currentUser,
    required IProductService productService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _currentUser = currentUser ?? CurrentUserProvider(),
        _productService = productService;

  @override
  Future<BatchModel?> getBatchById(String batchId) async {
    var doc = await _firestore
        .collection(FirestoreConstants.batches)
        .doc(batchId)
        .get();
    if (doc.exists) {
      var product =
          await _productService.getProduct(doc[FirestoreConstants.productId]);
      return BatchModel.fromSnapshot(doc, product);
    }
    return null;
  }

  @override
  Future<List<BatchModel>> getBatches(List<String> batchIds) async {
    var snapshot = await _firestore
        .collection(FirestoreConstants.batches)
        .where(FieldPath.documentId, whereIn: batchIds)
        .get();

    return snapshot.docs
        .map((doc) => BatchModel.fromSnapshot(doc, null))
        .toList();
  }

  @override
  Future<List<BatchModel>> getBatchesByProductId(String productId) async {
    var snapshot = await _firestore
        .collection(FirestoreConstants.batches)
        .where(FirestoreConstants.productId, isEqualTo: productId)
        .orderBy(FirestoreConstants.expiryDate, descending: false)
        .get();

    return snapshot.docs
        .map((doc) => BatchModel.fromSnapshot(doc, null))
        .toList();
  }

  @override
  Future<List<BatchModel>> getAllBatches() async {
    var snapshot = await _firestore
        .collection(FirestoreConstants.batches)
        .where(FirestoreConstants.sellerId, isEqualTo: _currentUser.uid)
        .orderBy(FirestoreConstants.expiryDate, descending: false)
        .get();

    return snapshot.docs
        .map((doc) => BatchModel.fromSnapshot(doc, null))
        .toList();
  }

  @override
  Future<void> addBatch({
    required String productId,
    String? batchNumber,
    required double price,
    required int stock,
    required String quantifier,
    required DateTime expiryDate,
    required int discount,
  }) async {
    final String generatedBatchNumber;

    if (batchNumber == null || batchNumber == '') {
      final datePart = DateFormat('yyyyMMdd').format(DateTime.now());
      final snapshot = await _firestore
          .collection(FirestoreConstants.batches)
          .where(FirestoreConstants.productId, isEqualTo: productId)
          .where(FirestoreConstants.batchNumber, isGreaterThanOrEqualTo: datePart)
          .where(FirestoreConstants.batchNumber, isLessThan: '$datePart\uf7ff')
          .orderBy(FirestoreConstants.batchNumber, descending: true)
          .limit(1)
          .get();

      int batchCount = 0;

      if (snapshot.docs.isNotEmpty) {
        final latestBatchNumber = snapshot.docs.first[FirestoreConstants.batchNumber] as String;
        AppLogger.debug('Latest batch number: $latestBatchNumber');

        final regex = RegExp(r'(\d+)$');
        final match = regex.firstMatch(latestBatchNumber);

        if (match != null) {
          final latestSuffix = int.tryParse(match.group(0) ?? '') ?? -1;
          AppLogger.debug('Latest suffix: $latestSuffix');
          batchCount = latestSuffix + 1;
        }
      }

      final suffix = batchCount.toString().padLeft(3, '0');
      generatedBatchNumber = '$datePart-$suffix';

      AppLogger.debug('Generated batch number: $generatedBatchNumber');
    } else {
      generatedBatchNumber = batchNumber;
    }

    await _firestore
        .collection(FirestoreConstants.batches)
        .doc(generatedBatchNumber)
        .set({
      FirestoreConstants.batchNumber: generatedBatchNumber,
      FirestoreConstants.productId: productId,
      FirestoreConstants.price: price,
      FirestoreConstants.stock: stock,
      FirestoreConstants.quantifier: quantifier,
      FirestoreConstants.expiryDate: Timestamp.fromDate(expiryDate),
      FirestoreConstants.discount: discount,
      FirestoreConstants.isListed: true,
      FirestoreConstants.dateCreated: Timestamp.now(),
      FirestoreConstants.sellerId: _currentUser.uid,
    });
  }

  @override
  Future<void> updateBatch(String batchNumber, double price, int stock,
      String quantifier, DateTime expiryDate, int discount) async {
    AppLogger.debug('Updating batch $batchNumber');

    await _firestore
        .collection(FirestoreConstants.batches)
        .doc(batchNumber)
        .update({
      FirestoreConstants.price: price,
      FirestoreConstants.stock: stock,
      FirestoreConstants.quantifier: quantifier,
      FirestoreConstants.expiryDate: Timestamp.fromDate(expiryDate),
      FirestoreConstants.discount: discount,
    });
  }

  @override
  Future<void> deleteBatch(String batchNumber) async {
    await _firestore
        .collection(FirestoreConstants.batches)
        .doc(batchNumber)
        .delete();
  }
}
