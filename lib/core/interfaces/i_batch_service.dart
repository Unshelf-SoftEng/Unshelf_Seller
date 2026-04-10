import 'package:unshelf_seller/models/batch_model.dart';

abstract class IBatchService {
  Future<BatchModel?> getBatchById(String batchId);
  Future<List<BatchModel>> getBatches(List<String> batchIds);
  Future<List<BatchModel>> getBatchesByProductId(String productId);
  Future<List<BatchModel>> getAllBatches();
  Future<void> addBatch({
    required String productId,
    String? batchNumber,
    required double price,
    required int stock,
    required String quantifier,
    required DateTime expiryDate,
    required int discount,
  });
  Future<void> updateBatch(String batchNumber, double price, int stock,
      String quantifier, DateTime expiryDate, int discount);
  Future<void> deleteBatch(String batchNumber);
}
