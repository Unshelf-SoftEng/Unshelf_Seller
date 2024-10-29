import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  TextEditingController batchNumberController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController stockController = TextEditingController();
  TextEditingController quantifierController = TextEditingController();
  TextEditingController discountController = TextEditingController();

  // Set loading state
  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  set expiryDate(DateTime? date) {
    _expiryDate = date;
    notifyListeners();
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

  Future<void> fetchBatch(String batchNumber) async {
    setLoading(true); // Trigger loading state to start
    try {
      final batch = await _batchService.getBatchById(batchNumber);
      if (batch != null) {
        batchNumber = batch.batchNumber;
        _expiryDate = batch.expiryDate;
        price = batch.price;
        stock = batch.stock;
        quantifier = batch.quantifier;
        discount = batch.discount;

        // Update controllers with retrieved values
        batchNumberController.text = batchNumber;
        expiryDateController.text =
            DateFormat('MM-dd-yyyy').format(batch.expiryDate);
        priceController.text = price.toString();
        stockController.text = stock.toString();
        quantifierController.text = quantifier ?? '';
        discountController.text = discount.toString();
      }
    } finally {
      setLoading(false); // End loading state to trigger rebuild
    }
  }

  Future<void> updateBatch() async {
    setLoading(true);

    print('Updating batch');

    await _batchService.updateBatch(
      batchNumberController.text,
      priceController.text.isNotEmpty
          ? double.tryParse(priceController.text) ?? 0.0
          : 0.0,
      stockController.text.isNotEmpty
          ? int.tryParse(stockController.text) ?? 0
          : 0,
      quantifierController.text.isNotEmpty ? quantifierController.text : '',
      expiryDate!,
      discountController.text.isNotEmpty
          ? int.tryParse(discountController.text) ?? 0
          : 0,
    );
    print('Batch updated');
    setLoading(false);
  }

  @override
  void dispose() {
    batchNumberController.dispose();
    expiryDateController.dispose();
    priceController.dispose();
    stockController.dispose();
    quantifierController.dispose();
    discountController.dispose();
    super.dispose();
  }
}
