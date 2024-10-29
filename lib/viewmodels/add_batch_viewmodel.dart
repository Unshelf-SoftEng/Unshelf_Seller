import 'package:flutter/material.dart';
import 'package:unshelf_seller/services/batch_service.dart';

class AddBatchViewModel extends ChangeNotifier {
  final BatchService _batchService = BatchService();

  String? batchNumber;
  DateTime? _expiryDate;
  double? price;
  int? stock;
  String? quantifier;
  int? discount;
  bool isLoading = false;
  DateTime? get expiryDate => _expiryDate;

  // Set loading state
  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  set expiryDate(DateTime? date) {
    _expiryDate = date;
    notifyListeners(); // Notify listeners when expiryDate changes
  }

  // Add batch using BatchService
  Future<void> addBatch(String productId) async {
    setLoading(true);
    await _batchService.addBatch(
      productId: productId,
      batchNumber: batchNumber,
      price: price!,
      stock: stock!,
      quantifier: quantifier!,
      expiryDate: expiryDate!,
      discount: discount!,
    );
    setLoading(false);
  }
}
