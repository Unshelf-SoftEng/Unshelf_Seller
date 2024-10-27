import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:unshelf_seller/models/product_model.dart';
import 'package:unshelf_seller/services/product_service.dart';

class ProductViewModel extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  String? productId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Uint8List? _mainImageData;
  Uint8List? get mainImageData => _mainImageData;

  List<Uint8List?> _additionalImageDataList = [];
  List<Uint8List?> get additionalImageDataList => _additionalImageDataList;

  bool _isMainImageNew = false;
  List<bool> _isAdditionalImageNewList = List.generate(4, (_) => false);

  bool _errorFound = false;
  bool get errorFound => _errorFound;

  String selectedCategory = '';
  List<String> categories = [
    'Grocery',
    'Fruits',
    'Vegetables',
    'Baked Goods',
  ];

  final ProductService _productService = ProductService();

  ProductViewModel({required this.productId}) {
    if (productId != null) fetchProductData();
  }

  Future<void> fetchProductData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final product = await _productService.getProduct(productId!);

      if (product != null) {
        nameController.text = product.name;
        descriptionController.text = product.description;
        selectedCategory = product.category;
        String? _mainImageUrl = product.mainImageUrl;
        List<String>? _additionalImageUrls = product.additionalImageUrls;

        await loadImageFromUrl(_mainImageUrl, true);

        // Load additional images if available
        if (_additionalImageUrls != null) {
          for (int i = 0; i < _additionalImageUrls.length; i++) {
            if (i < _additionalImageDataList.length) {
              await loadImageFromUrl(_additionalImageUrls[i], false, index: i);
            }
          }
        }
      }
    } catch (e) {
      // Handle errors
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadImageFromUrl(String imageUrl, bool isMainImage,
      {int? index}) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        if (isMainImage) {
          _mainImageData = response.bodyBytes;
        } else if (index != null) {
          _additionalImageDataList![index] = response.bodyBytes;
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error loading image: $e');
    }
  }

  Future<void> pickImage(bool isMainImage, {int? index}) async {
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final Uint8List imageData = await image.readAsBytes();
      print('Picked Image Data: $imageData'); // Debugging

      if (isMainImage) {
        _mainImageData = imageData;
        _isMainImageNew = true;
      } else if (index != null) {
        _additionalImageDataList.add(imageData);
        _isAdditionalImageNewList.add(true);
      }

      print('Updated Additional Image Data List: $_additionalImageDataList');

      notifyListeners();
    }
  }

  Future<List<String>> uploadImages() async {
    List<String> downloadUrls = [];

    if (_mainImageData != null && _isMainImageNew) {
      try {
        final mainImageRef = FirebaseStorage.instance.ref().child(
            'product_images/main_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await mainImageRef.putData(_mainImageData!);
        final mainImageUrl = await mainImageRef.getDownloadURL();
        downloadUrls.add(mainImageUrl);
      } catch (e) {
        // Handle error
      }
    }

    for (int i = 0; i < _additionalImageDataList!.length; i++) {
      if (_additionalImageDataList![i] != null &&
          _isAdditionalImageNewList[i]) {
        try {
          final additionalImageRef = FirebaseStorage.instance.ref().child(
              'product_images/additional_${DateTime.now().millisecondsSinceEpoch}_$i.jpg');
          await additionalImageRef.putData(_additionalImageDataList![i]!);
          final additionalImageUrl = await additionalImageRef.getDownloadURL();
          downloadUrls.add(additionalImageUrl);
        } catch (e) {
          // Handle error
        }
      }
    }

    return downloadUrls;
  }

  Future<void> addOrUpdateProductImages() async {
    if (_mainImageData == null) {
      _errorFound = true;
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      User? user = FirebaseAuth.instance.currentUser;
      List<String> imageUrls = await uploadImages();

      final mainImageUrl = imageUrls.isNotEmpty ? imageUrls.removeAt(0) : null;

      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update({
        'mainImageUrl': mainImageUrl,
        'additionalImageUrls': imageUrls,
      });
    } on FirebaseAuthException catch (e) {
      // Handle authentication error
    } catch (e) {
      // Handle other errors
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void deleteMainImage() {
    _mainImageData = null;
    _isMainImageNew = false;
    notifyListeners();
  }

  void deleteAdditionalImage(int index) {
    _additionalImageDataList.removeAt(index);
    _isAdditionalImageNewList.removeAt(index);
    notifyListeners();
  }

  Future<void> addProduct(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      _isLoading = true;
      notifyListeners();
      try {
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          List<String> images = await uploadImages();

          ProductModel product = ProductModel(
            id: '',
            name: nameController.text,
            description: descriptionController.text,
            category: selectedCategory,
            mainImageUrl: images[0],
            additionalImageUrls: images.sublist(1),
          );

          await _productService.addProduct(product);
        }
      } catch (e) {
        print('Error adding product' + e.toString());
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> updateProduct(BuildContext context, String productId) async {
    if (formKey.currentState!.validate()) {
      _isLoading = true;
      notifyListeners();
      try {
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          List<String> images = await uploadImages();

          await FirebaseFirestore.instance
              .collection('products')
              .doc(productId)
              .update({
            'name': nameController.text,
            'description': descriptionController.text,
            'category': selectedCategory,
            'discount': int.parse(discountController.text),
            'mainImageUrl': images[0],
            'additionalImageUrls': images.sublist(1),
          });
        } else {}
      } catch (e) {
        // Handle errors
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    discountController.dispose();
    super.dispose();
  }
}
