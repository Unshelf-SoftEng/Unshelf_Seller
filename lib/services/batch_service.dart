import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/models/batch_model.dart';
import 'package:intl/intl.dart';

class BatchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<BatchModel?> getBatchById(String batchId) async {
    var doc = await _firestore.collection('batches').doc(batchId).get();
    if (doc.exists) {
      var productDoc =
          await _firestore.collection('products').doc(doc['sellerId']).get();

      return BatchModel.fromSnapshot(doc, null);
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

  Future<void> addBatch({
    required String productId,
    String? batchNumber,
    required double price,
    required int stock,
    required String quantifier,
    required DateTime expiryDate,
    required int discount,
  }) async {
    final datePart = DateFormat('yyyyMMdd').format(DateTime.now());
    final snapshot = await _firestore
        .collection('batches') // Replace 'batches' with your collection name
        .where('batchNumber', isGreaterThanOrEqualTo: datePart)
        .where('batchNumber', isLessThan: '$datePart\uf8ff')
        .orderBy('batchNumber', descending: true)
        .limit(1)
        .get();

    int batchCount = 1;

    if (snapshot.docs.isNotEmpty) {
      // Get the last two characters of the latest batch number
      final latestBatchNumber = snapshot.docs.first['batchNumber'] as String;
      final latestSuffix = int.tryParse(
              latestBatchNumber.substring(latestBatchNumber.length - 2)) ??
          0;
      batchCount = latestSuffix + 1;
    }

    final suffix = batchCount.toString().padLeft(2, '0');

    final generatedBatchNumber = batchNumber ?? '$datePart-$suffix';

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
    });
  }

  Future<void> deleteBatch(String batchNumber) async {
    await _firestore.collection('batches').doc(batchNumber).delete();
  }
}
