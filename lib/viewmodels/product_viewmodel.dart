import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:unshelf_seller/models/product_model.dart';
import 'package:unshelf_seller/services/product_service.dart';
import 'package:http/http.dart' as http;
import 'package:unshelf_seller/utils/colors.dart';

class ProductViewModel extends ChangeNotifier {
  TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ImageState _mainImageState = ImageState();
  ImageState get mainImageState => _mainImageState;

  List<ImageState> _additionalImages = [];
  List<ImageState> get additionalImages => _additionalImages;

  ProductModel? _selectedProduct;
  ProductModel? get selectedProduct => _selectedProduct;

  String get selectedProductId => _selectedProductId;

  String _selectedProductId = '';

  String selectedCategory = '';
  List<String> categories = ['Grocery', 'Fruits', 'Vegetables', 'Baked Goods'];

  bool _errorFound = false;

  bool get errorFound => _errorFound;

  set errorFound(bool value) {
    _errorFound = value;
    notifyListeners(); // Notify the UI about the change
  }

  Future<bool> addProductWithValidation(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    if (mainImageState.data == null) {
      errorFound = true;
      _showSnackBar(context, 'Please add a main image!');
      return false;
    }

    if (!(formKey.currentState?.validate() ?? false)) {
      _showSnackBar(context, 'Please fill out all required fields!');
      return false;
    }

    await addProduct(context);
    _showSnackBar(context, 'Product added successfully!', isSuccess: true);
    return true;
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isSuccess ? AppColors.primaryColor : AppColors.warningColor,
      ),
    );
  }

  final ProductService _productService = ProductService();

  Future<void> loadProduct(ProductModel product) async {
    _isLoading = true;
    notifyListeners();
    nameController.text = product.name;
    descriptionController.text = product.description;
    selectedCategory = product.category;

    // Load main image

    _mainImageState = ImageState(url: product.mainImageUrl);
    await _mainImageState.loadImageData();

    if (product.additionalImageUrls != null &&
        product.additionalImageUrls!.isNotEmpty) {
      _additionalImages =
          await Future.wait(product.additionalImageUrls!.map((url) async {
        final imageState = ImageState(url: url);
        await imageState.loadImageData();
        return imageState;
      }).toList());
    } else {
      _additionalImages = []; // Explicitly set to empty list if no images
    }
    _selectedProduct = product;

    print('Product loaded: $product');
    _isLoading = false;
    notifyListeners();
  }

  // Pick and add image to the respective list
  Future<void> pickImage(bool isMainImage) async {
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final Uint8List imageData = await image.readAsBytes();

      if (isMainImage) {
        _mainImageState = ImageState(data: imageData, isNew: true);
      } else {
        _additionalImages.add(ImageState(data: imageData, isNew: true));
      }

      if (errorFound) {
        errorFound = false;
      }

      notifyListeners();
    }
  }

  // Upload image and return URL
  Future<String> uploadImage(Uint8List imageData, int? index) async {
    final Reference imageRef;

    if (index == null) {
      imageRef = FirebaseStorage.instance.ref().child(
          'product_images/main_${DateTime.now().millisecondsSinceEpoch}.jpg');
    } else {
      imageRef = FirebaseStorage.instance.ref().child(
          'product_images/additional_${DateTime.now().millisecondsSinceEpoch}_$index.jpg');
    }

    await imageRef.putData(imageData);
    return await imageRef.getDownloadURL();
  }

  void deleteImage(bool isMainImage, int? index) {
    if (isMainImage) {
      _mainImageState = ImageState(isNew: true);
    } else if (index != null && index < _additionalImages.length) {
      _additionalImages.removeAt(index);
    }

    notifyListeners();
  }

  // Add or update product with the uploaded images
  Future<void> addProduct(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      _isLoading = true;
      notifyListeners();

      try {
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          ProductModel product = ProductModel(
            id: '',
            name: nameController.text,
            description: descriptionController.text,
            category: selectedCategory,
            mainImageUrl: await uploadImage(_mainImageState.data!, null),
            additionalImageUrls: [],
          );

          _selectedProductId = await _productService.addProduct(product);
        }
      } catch (e) {
        print('Error adding product' + e.toString());
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // Update product with the uploaded images
  Future<bool> updateProduct(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      _isLoading = true;
      notifyListeners();

      if (mainImageState.isNew && mainImageState.data == null) {
        errorFound = true;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      try {
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          final productRef = FirebaseFirestore.instance
              .collection('products')
              .doc(_selectedProduct?.id);

          await FirebaseFirestore.instance.runTransaction((transaction) async {
            final snapshot = await transaction.get(productRef);
            if (!snapshot.exists) {
              throw Exception("Product does not exist!");
            }

            final currentData = snapshot.data() as Map<String, dynamic>;

            Map<String, dynamic> updatedFields = {};

            if (nameController.text != currentData['name']) {
              updatedFields['name'] = nameController.text;
            }
            if (descriptionController.text != currentData['description']) {
              updatedFields['description'] = descriptionController.text;
            }
            if (selectedCategory != currentData['category']) {
              updatedFields['category'] = selectedCategory;
            }

            if (_mainImageState.isNew) {
              updatedFields['mainImageUrl'] =
                  await uploadImage(_mainImageState.data!, null);
            }

            for (int i = 0; i < _additionalImages.length; i++) {
              if (_additionalImages[i].isNew) {
                additionalImages[i].url =
                    await uploadImage(_additionalImages[i].data!, i);
              }
            }

            updatedFields['additionalImageUrls'] =
                _additionalImages.map((imageState) => imageState.url).toList();

            if (updatedFields.isNotEmpty) {
              transaction.update(productRef, updatedFields);
            }
          });

          return true;
        }
      } catch (e) {
        print('Error updating product: $e');
        return false;
      }
    }

    return false;
  }

  // Clear all data
  void clearData() {
    nameController.clear();
    descriptionController.clear();
    selectedCategory = '';
    _mainImageState = ImageState();
    _additionalImages.clear();
  }
}

class ImageState {
  Uint8List? data;
  String? url;
  bool isNew;
  bool isDeleted;

  ImageState({
    this.data,
    this.url,
    this.isNew = false,
    this.isDeleted = false,
  });

  Future<void> loadImageData() async {
    if (url != null) {
      try {
        final response = await http.get(Uri.parse(url!));
        if (response.statusCode == 200) {
          data = response.bodyBytes;
        } else {
          print("Failed to load image from URL.");
        }
      } catch (e) {
        print("Error loading image: $e");
      }
    }
  }
}
