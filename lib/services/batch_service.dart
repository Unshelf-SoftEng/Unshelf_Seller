import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/models/batch_model.dart';

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
}
