import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unshelf_seller/services/batch_service.dart';

class BatchViewModel extends ChangeNotifier {
  final BatchService _batchService = BatchService();

  String? _batchNumber;
  DateTime? _expiryDate;
  double? price;
  int? stock;
  String? quantifier;
  int? discount;
  bool isLoading = false;
  DateTime? get expiryDate => _expiryDate;
  String? get batchNumber => _batchNumber;

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
      batchNumber: batchNumberController.text,
      price: double.tryParse(priceController.text) ?? 0.0,
      stock: int.tryParse(stockController.text) ?? 0,
      quantifier: quantifierController.text,
      expiryDate: expiryDate!,
      discount: discountController.text.isNotEmpty
          ? int.tryParse(discountController.text) ?? 0
          : 0,
    );
    setLoading(false);
  }

  Future<void> fetchBatch(String batchNumber) async {
    setLoading(true);
    try {
      _batchNumber = batchNumber;
      final batch = await _batchService.getBatchById(batchNumber);
      if (batch != null) {
        batchNumberController.text = batchNumber;
        expiryDateController.text =
            DateFormat('MM-dd-yyyy').format(batch.expiryDate);
        priceController.text = batch.price.toString();
        stockController.text = batch.stock.toString();
        quantifierController.text = batch.quantifier;
        discountController.text = batch.discount.toString();
      }
    } finally {
      setLoading(false);
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

  void clearData() {
    batchNumberController.clear();
    expiryDateController.clear();
    priceController.clear();
    stockController.clear();
    quantifierController.clear();
    discountController.clear();
    _batchNumber = null;
    _expiryDate = null;
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
