import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:unshelf_seller/core/base_viewmodel.dart';
import 'package:unshelf_seller/core/interfaces/i_batch_service.dart';
import 'package:unshelf_seller/core/interfaces/i_bundle_service.dart';
import 'package:unshelf_seller/core/logger.dart';
import 'package:unshelf_seller/models/bundle_model.dart';

class BundleViewModel extends BaseViewModel {
  final IBundleService _bundleService;
  final IBatchService _batchService;

  BundleViewModel({
    required IBundleService bundleService,
    required IBatchService batchService,
  })  : _bundleService = bundleService,
        _batchService = batchService;

  final TextEditingController bundleNameController = TextEditingController();
  final TextEditingController bundlePriceController = TextEditingController();
  final TextEditingController bundleStockController = TextEditingController();
  final TextEditingController bundleDiscountController =
      TextEditingController();
  final TextEditingController bundleDescriptionController =
      TextEditingController();
  final formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  Uint8List? _mainImageData;
  Uint8List? get mainImageData => _mainImageData;

  BundleModel? _bundle;
  BundleModel? get bundle => _bundle;

  String selectedCategory = '';
  List<String> categories = [
    'Grocery',
    'Fruits',
    'Vegetables',
    'Baked Goods',
  ];

  final bool _errorFound = false;
  bool get errorFound => _errorFound;

  void initializeControllers(BundleModel bundle) {
    bundleNameController.text = bundle.name;
    bundlePriceController.text = bundle.price.toString();
    bundleStockController.text = bundle.stock.toString();
    bundleDiscountController.text = bundle.discount.toString();
    bundleDescriptionController.text = bundle.description;
    _updateBundleStock();
  }

  void _updateBundleStock() {
    notifyListeners();
  }

  Future<void> createBundle(
      Map<String, Map<String, dynamic>> productDetails) async {
    try {
      final bundleName = bundleNameController.text;
      final bundlePrice = double.tryParse(bundlePriceController.text) ?? 0.0;
      final bundleStock = int.tryParse(bundleStockController.text) ?? 0;
      final bundleDiscount = int.tryParse(bundleDiscountController.text) ?? 0;
      final bundleDescription = bundleDescriptionController.text;

      final mainImageRef = FirebaseStorage.instance
          .ref()
          .child('bundle_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      await mainImageRef.putData(_mainImageData!);

      final mainImageUrl = await mainImageRef.getDownloadURL();

      BundleModel bundle = BundleModel(
        id: '',
        name: bundleName,
        mainImageUrl: mainImageUrl,
        description: bundleDescription,
        category: selectedCategory,
        items: productDetails.entries
            .map((entry) => {
                  'batchId': entry.key,
                  'quantity': entry.value['quantity'],
                  'quantifier': entry.value['quantifier'],
                })
            .toList(),
        price: bundlePrice,
        stock: bundleStock,
        discount: bundleDiscount,
      );

      _bundleService.createBundle(bundle);
      AppLogger.debug('Bundle created successfully');
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to create bundle: $e');
    }
  }

  Future<void> loadImageFromUrl(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        _mainImageData = response.bodyBytes;
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Error loading image: $e');
    }
  }

  Future<void> pickImage() async {
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final Uint8List imageData = await image.readAsBytes();

      _mainImageData = imageData;
      notifyListeners();
    }
  }

  void deleteImage() {
    _mainImageData = null;
    notifyListeners();
  }

  Future<void> getBundleDetails(String bundleId) async {
    setLoading(true);
    notifyListeners();
    // Fetch bundle details
    _bundle = await _bundleService.getBundle(bundleId);

    for (var item in _bundle!.items) {
      final batch = await _batchService.getBatchById(item['batchId']);
      item['name'] = batch!.product!.name;
      item['imageUrl'] = batch.product!.mainImageUrl;
    }

    // Load main image
    await loadImageFromUrl(_bundle!.mainImageUrl);
    setLoading(false);
    notifyListeners();
  }

  Future<void> initializeBundle(String bundleId) async {
    setLoading(true);
    notifyListeners();
    if (bundleId.isNotEmpty) {
      await getBundleDetails(bundleId);
    }

    bundleNameController.text = _bundle!.name;
    bundleDescriptionController.text = _bundle!.description;
    bundlePriceController.text = _bundle!.price.toString();
    bundleStockController.text = _bundle!.stock.toString();
    bundleDiscountController.text = _bundle!.discount.toString();
    selectedCategory = _bundle!.category;

    AppLogger.debug('category: $selectedCategory');
    AppLogger.debug('Bundle initialized successfully');

    setLoading(false);
    notifyListeners();
  }

  Future<void> updateBundle() async {
    try {
      final bundleName = bundleNameController.text;
      final bundlePrice = double.tryParse(bundlePriceController.text) ?? 0.0;
      final bundleStock = int.tryParse(bundleStockController.text) ?? 0;
      final bundleDiscount = int.tryParse(bundleDiscountController.text) ?? 0;
      final bundleDescription = bundleDescriptionController.text;

      final mainImageRef = FirebaseStorage.instance
          .ref()
          .child('bundle_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      await mainImageRef.putData(_mainImageData!);

      final mainImageUrl = await mainImageRef.getDownloadURL();

      BundleModel updatedBundle = BundleModel(
        id: _bundle!.id,
        name: bundleName,
        mainImageUrl: mainImageUrl,
        description: bundleDescription,
        category: selectedCategory,
        items: _bundle!.items,
        price: bundlePrice,
        stock: bundleStock,
        discount: bundleDiscount,
      );

      _bundleService.updateBundle(updatedBundle);
      AppLogger.debug('Bundle updated successfully');
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to update bundle: $e');
    }
  }

  void clearSelection() {
    bundleNameController.clear();
    bundlePriceController.clear();
    bundleStockController.clear();
    bundleDiscountController.clear();
    bundleDescriptionController.clear();
    _mainImageData = null;
    selectedCategory = '';
    notifyListeners();
  }
}
