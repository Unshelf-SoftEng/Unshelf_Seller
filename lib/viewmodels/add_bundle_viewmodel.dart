import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:unshelf_seller/models/product_model.dart';
import 'package:unshelf_seller/models/bundle_model.dart';
import 'package:unshelf_seller/services/bundle_service.dart';

class AddBundleViewModel extends ChangeNotifier {
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

  String selectedCategory = '';
  List<String> categories = [
    'Grocery',
    'Fruits',
    'Vegetables',
    'Baked Goods',
  ];

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
    // Fetch bundle details
    _bundle = await _bundleService.getBundle(bundleId);
    notifyListeners();

    // Load main image
    await loadImageFromUrl(_bundle!.mainImageUrl);
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
