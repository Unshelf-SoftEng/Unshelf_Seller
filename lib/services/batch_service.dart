import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unshelf_seller/models/batch_model.dart';
import 'package:intl/intl.dart';
import 'package:unshelf_seller/services/product_service.dart';

class BatchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductService _productService = ProductService();

  Future<BatchModel?> getBatchById(String batchId) async {
    var doc = await _firestore.collection('batches').doc(batchId).get();
    if (doc.exists) {
      var product = await _productService.getProduct(doc['productId']);
      return BatchModel.fromSnapshot(doc, product);
    }
    return null;
  }

  Future<List<BatchModel>> getBatches(List<String> batchIds) async {
    var snapshot = await _firestore
        .collection('batches')
        .where(FieldPath.documentId, whereIn: batchIds)
        .get();

    return snapshot.docs
        .map((doc) => BatchModel.fromSnapshot(doc, null))
        .toList();
  }

  Future<List<BatchModel>> getBatchesByProductId(String productId) async {
    var snapshot = await _firestore
        .collection('batches')
        .where('productId', isEqualTo: productId)
        .orderBy('expiryDate', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => BatchModel.fromSnapshot(doc, null))
        .toList();
  }

  Future<List<BatchModel>> getAllBatches() async {
    User? user = FirebaseAuth.instance.currentUser;
    var snapshot = await _firestore
        .collection('batches')
        .where('sellerId', isEqualTo: user!.uid)
        .orderBy('expiryDate', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => BatchModel.fromSnapshot(doc, null))
        .toList();
  }

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
          .collection('batches')
          .where('productId', isEqualTo: productId)
          .where('batchNumber', isGreaterThanOrEqualTo: datePart)
          .where('batchNumber', isLessThan: '$datePart\uf7ff')
          .orderBy('batchNumber', descending: true)
          .limit(1)
          .get();

      int batchCount = 0;

      if (snapshot.docs.isNotEmpty) {
        final latestBatchNumber = snapshot.docs.first['batchNumber'] as String;
        print('Latest batch number: $latestBatchNumber');

        // Extract the numeric suffix after the last '-'
        final regex =
            RegExp(r'(\d+)$'); // Matches the numeric part after the last '-'
        final match = regex.firstMatch(latestBatchNumber);

        if (match != null) {
          final latestSuffix = int.tryParse(match.group(0) ?? '') ??
              -1; // Parse the numeric part
          print('Latest suffix: $latestSuffix');
          batchCount = latestSuffix + 1; // Increment the suffix by 1
        }
      }

      final suffix = batchCount
          .toString()
          .padLeft(3, '0'); // Ensure the suffix is always 3 digits
      generatedBatchNumber = '$datePart-$suffix';

      print('Generated batch number: $generatedBatchNumber');
    } else {
      generatedBatchNumber = batchNumber;
    }
    // Save the batch to Firestore
    await _firestore.collection('batches').doc(generatedBatchNumber).set({
      'batchNumber': generatedBatchNumber,
      'productId': productId,
      'price': price,
      'stock': stock,
      'quantifier': quantifier,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'discount': discount,
      'isListed': true,
      'dateCreated': Timestamp.now(),
      'sellerId': FirebaseAuth.instance.currentUser!.uid,
    });
  }

  Future<void> updateBatch(String batchNumber, double price, int stock,
      String quantifier, DateTime expiryDate, int discount) async {
    print('Updating batch');
    print(expiryDate);
    var formattedDate = Timestamp.fromDate(expiryDate);
    print(formattedDate);

    await _firestore.collection('batches').doc(batchNumber).update({
      'price': price,
      'stock': stock,
      'quantifier': quantifier,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'discount': discount,
    });
  }

  Future<void> deleteBatch(String batchNumber) async {
    await _firestore.collection('batches').doc(batchNumber).delete();
  }
}
