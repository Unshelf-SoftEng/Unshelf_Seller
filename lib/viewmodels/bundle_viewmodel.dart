import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:unshelf_seller/models/product_model.dart';
import 'package:unshelf_seller/models/bundle_model.dart';
import 'package:unshelf_seller/services/bundle_service.dart';
import 'package:unshelf_seller/services/batch_service.dart';

class BundleViewModel extends ChangeNotifier {
  final TextEditingController bundleNameController = TextEditingController();
  final TextEditingController bundlePriceController = TextEditingController();
  final TextEditingController bundleStockController = TextEditingController();
  final TextEditingController bundleDiscountController =
      TextEditingController();
  final TextEditingController bundleDescriptionController =
      TextEditingController();
  final formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  List<ProductModel> _products = [];
  int _maxStock = 0;

  List<ProductModel> get products => _products;
  int get maxStock => _maxStock;

  Uint8List? _mainImageData;
  Uint8List? get mainImageData => _mainImageData;

  final BundleService _bundleService = BundleService();
  BundleModel? _bundle;
  BundleModel? get bundle => _bundle;

  final BatchService _batchService = BatchService();

  String selectedCategory = '';
  List<String> categories = [
    'Grocery',
    'Fruits',
    'Vegetables',
    'Baked Goods',
  ];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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

      BundleModel bundle = new BundleModel(
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
      print('Bundle created successfully');
      notifyListeners();
    } catch (e) {
      print('Failed to create bundle: $e');
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
      print('Error loading image: $e');
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

  void deleteMainImage() {
    _mainImageData = null;
    notifyListeners();
  }

  Future<void> getBundleDetails(String bundleId) async {
    _isLoading = true;
    notifyListeners();
    // Fetch bundle details
    _bundle = await _bundleService.getBundle(bundleId);

    print('Bundle details fetched successfully');
    print('Bundle: $_bundle');
    print('Main image: $_mainImageData');
    print('Items: ${_bundle!.items}');
    print('Category: ${_bundle!.category}');
    print('Description: ${_bundle!.description}');
    print('Price: ${_bundle!.price}');

    for (var item in _bundle!.items) {
      final batch = await _batchService.getBatchById(item['batchId']);
      item['name'] = batch!.product!.name;
    }

    // Load main image
    await loadImageFromUrl(_bundle!.mainImageUrl);

    print('Bundle details fetched successfully');
    print('Bundle: $_bundle');
    print('Main image: $_mainImageData');
    print('Items: ${_bundle!.items}');
    print('Category: ${_bundle!.category}');
    print('Description: ${_bundle!.description}');
    print('Price: ${_bundle!.price}');

    _isLoading = false;
    notifyListeners();
  }

  void clearSelection() {
    bundleNameController.clear();
    bundlePriceController.clear();
    bundleStockController.clear();
    bundleDiscountController.clear();
    _mainImageData = null;
    selectedCategory = '';
    notifyListeners();
  }
}
