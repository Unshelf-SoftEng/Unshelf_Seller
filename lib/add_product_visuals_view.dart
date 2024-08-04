import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class AddProductView extends StatefulWidget {
  final String? productId;

  AddProductView({this.productId});

  @override
  _AddProductViewState createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _productQuantityController =
      TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  Uint8List? _imageData;
  bool _isImageNew = false;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) _fetchProductData();
  }

  Future<void> _fetchProductData() async {
    final productDoc = await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .get();

    if (productDoc.exists) {
      final productData = productDoc.data() as Map<String, dynamic>;
      _productNameController.text = productData['name'];
      _productPriceController.text = productData['price'].toString();
      _productQuantityController.text = productData['quantity'].toString();
      _expiryDateController.text = productData['expiry_date'];
      _loadImageFromUrl(productData['image_url']);
    }
  }

  Future<void> _loadImageFromUrl(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        setState(() {
          _imageData = response.bodyBytes;
        });
      } else {
        // Handle error
        print('Failed to load image');
      }
    } catch (e) {
      // Handle error
      print('Error loading image: $e');
    }
  }

  Future<void> _pickImage() async {
    XFile? image;

    if (kIsWeb) {
      // Web-specific image picking
      image = await _picker.pickImage(source: ImageSource.gallery);
    } else {
      // Mobile-specific image picking
      image = await _picker.pickImage(source: ImageSource.gallery);
    }

    if (image != null) {
      // Read image bytes asynchronously
      final Uint8List imageData = await image.readAsBytes();

      // Update state
      setState(() {
        _imageData = imageData;
        _isImageNew = true;
      });
    }
  }

  Future<String> _uploadImage() async {
    if (_imageData != null && _isImageNew) {
      try {
        final storageRef = FirebaseStorage.instance.ref().child(
            'product_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await storageRef.putData(_imageData!);
        final downloadUrl = await storageRef.getDownloadURL();
        return downloadUrl;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: ${e.toString()}')),
        );
        return '';
      }
    }
    return '';
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _expiryDateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> addOrUpdateProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        User? user = FirebaseAuth.instance.currentUser;

        double price;
        try {
          price = double.parse(_productPriceController.text);
        } catch (e) {
          throw FormatException('Invalid price format');
        }

        String? imageUrl = await _uploadImage();

        if (user != null) {
          if (widget.productId == null) {
            // Add new product
            await FirebaseFirestore.instance.collection('products').add({
              'name': _productNameController.text,
              'price': price,
              'seller_id': user.uid,
              'image_url': imageUrl,
              'quantity': int.tryParse(_productQuantityController.text) ?? 0,
              'expiry_date': _expiryDateController.text,
            });
          } else {
            // Update existing product
            await FirebaseFirestore.instance
                .collection('products')
                .doc(widget.productId)
                .update({
              'name': _productNameController.text,
              'price': price,
              'image_url': imageUrl,
              'quantity': int.tryParse(_productQuantityController.text) ?? 0,
              'expiry_date': _expiryDateController.text,
            });
          }
          Navigator.pop(context);
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication error: ${e.message}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _productPriceController.dispose();
    _productQuantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productId == null ? 'Add Product' : 'Edit Product'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.green, width: 5), // Thick border
                        color: Colors.transparent,
                      ),
                    ),
                    Center(
                        child: Text(
                      '1/2',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ))
                  ],
                ),
                SizedBox(width: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Product Details',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                      'Enter product details',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                )
              ]),

              TextFormField(
                controller: _productNameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _productPriceController,
                decoration: const InputDecoration(
                  labelText: 'Product Price',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  try {
                    double.parse(value);
                  } catch (e) {
                    return 'Invalid price format';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _productQuantityController,
                decoration: const InputDecoration(
                  labelText: 'Product Quantity',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*')),
                ],
              ),
              TextFormField(
                controller: _expiryDateController,
                decoration: const InputDecoration(
                  labelText: 'Expiry Date',
                ),
                readOnly: true,
                onTap: () => _selectExpiryDate(context),
              ),
              // Image Picking and Display:
              ElevatedButton(
                onPressed: _pickImage, // Trigger image picking
                child: const Text('Pick Image'),
              ),
              const SizedBox(height: 20),
              _imageData != null
                  ? Image.memory(
                      _imageData!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : const Text('No image selected'),
              const SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: addOrUpdateProduct,
                      child: Text(widget.productId == null
                          ? 'Add Product'
                          : 'Update Product'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
