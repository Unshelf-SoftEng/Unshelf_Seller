import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ProductSummaryView extends StatefulWidget {
  final String? productId;

  ProductSummaryView({this.productId});

  @override
  _ProductSummaryViewState createState() => _ProductSummaryViewState();
}

class _ProductSummaryViewState extends State<ProductSummaryView> {
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  Uint8List? _mainImageData;
  List<Uint8List?> _additionalImageDataList = List.generate(4, (_) => null);
  bool _isMainImageNew = false;
  List<bool> _isAdditionalImageNewList = List.generate(4, (_) => false);
  bool _errorFound = false;

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
      final mainImageUrl = productData['image_url'];
      final additionalImageUrls =
          List<String>.from(productData['additional_image_urls'] ?? []);

      if (mainImageUrl != null) {
        await _loadImageFromUrl(mainImageUrl, true);
      }

      for (int i = 0; i < additionalImageUrls.length; i++) {
        if (i < _additionalImageDataList.length) {
          await _loadImageFromUrl(additionalImageUrls[i], false, index: i);
        }
      }
    }
  }

  Future<void> _loadImageFromUrl(String imageUrl, bool isMainImage,
      {int? index}) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        setState(() {
          if (isMainImage) {
            _mainImageData = response.bodyBytes;
          } else if (index != null) {
            _additionalImageDataList[index] = response.bodyBytes;
          }
        });
      } else {
        print('Failed to load image');
      }
    } catch (e) {
      print('Error loading image: $e');
    }
  }

  Future<void> _pickImage(bool isMainImage, {int? index}) async {
    XFile? image;

    if (kIsWeb) {
      image = await _picker.pickImage(source: ImageSource.gallery);
    } else {
      image = await _picker.pickImage(source: ImageSource.gallery);
    }

    if (image != null) {
      final Uint8List imageData = await image.readAsBytes();

      setState(() {
        if (isMainImage) {
          _mainImageData = imageData;
          _isMainImageNew = true;
        } else if (index != null) {
          _additionalImageDataList[index] = imageData;
          _isAdditionalImageNewList[index] = true;
        }
      });
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> downloadUrls = [];

    if (_mainImageData != null && _isMainImageNew) {
      try {
        final mainImageRef = FirebaseStorage.instance.ref().child(
            'product_images/main_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await mainImageRef.putData(_mainImageData!);
        final mainImageUrl = await mainImageRef.getDownloadURL();
        downloadUrls.add(mainImageUrl);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error uploading main image: ${e.toString()}')),
        );
      }
    }

    for (int i = 0; i < _additionalImageDataList.length; i++) {
      if (_additionalImageDataList[i] != null && _isAdditionalImageNewList[i]) {
        try {
          final additionalImageRef = FirebaseStorage.instance.ref().child(
              'product_images/additional_${DateTime.now().millisecondsSinceEpoch}_$i.jpg');
          await additionalImageRef.putData(_additionalImageDataList[i]!);
          final additionalImageUrl = await additionalImageRef.getDownloadURL();
          downloadUrls.add(additionalImageUrl);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Error uploading additional image $i: ${e.toString()}')),
          );
        }
      }
    }

    return downloadUrls;
  }

  Future<void> addOrUpdateProductImages() async {
    if (_mainImageData == null) {
      setState(() {
        _errorFound = true;
      });
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        User? user = FirebaseAuth.instance.currentUser;
        List<String> imageUrls = await _uploadImages();

        final mainImageUrl =
            imageUrls.isNotEmpty ? imageUrls.removeAt(0) : null;

        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .update({
          'main_image_url': mainImageUrl,
          'additional_image_urls': imageUrls,
        });

        Navigator.pop(context);
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

  void _deleteImage(int index) {
    setState(() {
      _additionalImageDataList[index] = null;
      _isAdditionalImageNewList[index] = false;
      // Shift images to the left
      for (int i = index; i < _additionalImageDataList.length - 1; i++) {
        _additionalImageDataList[i] = _additionalImageDataList[i + 1];
        _isAdditionalImageNewList[i] = _isAdditionalImageNewList[i + 1];
      }
      _additionalImageDataList[_additionalImageDataList.length - 1] = null;
      _isAdditionalImageNewList[_additionalImageDataList.length - 1] = false;
    });
  }

  void deleteMainImage() {
    setState(() {
      _mainImageData = null;
      _isMainImageNew = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Images'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.green, width: 5), // Thick border
                        color: Colors.transparent,
                      ),
                    ),
                    const Center(
                      child: Text(
                        '2/2',
                        style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Product Summary Details',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    Text(
                      'Please review the product details',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                )
              ]),
              const SizedBox(height: 16.0),
              GestureDetector(
                onTap: () => _pickImage(true),
                child: Container(
                  width: double.infinity,
                  height: 350,
                  color: const Color(0xFF386641),
                  child: _mainImageData != null
                      ? ImageWithDelete(
                          imageData: _mainImageData!,
                          onDelete: deleteMainImage,
                          width: 400.0,
                          height: 400.0, // Add border
                          margin: EdgeInsets.all(0),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, color: Colors.white),
                              Text(
                                'Add Main Image',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (_additionalImageDataList.any((image) =>
                      image == null)) // Show the add button if there's space
                    GestureDetector(
                      onTap: () => _pickImage(false,
                          index: _additionalImageDataList.indexOf(null)),
                      child: Container(
                        width: 90,
                        height: 90,
                        margin: EdgeInsets.only(right: 8.0),
                        color: const Color(0xFF386641),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, color: Colors.white),
                              Text(
                                'Other Images',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ...List.generate(4, (index) {
                    return _additionalImageDataList[index] != null
                        ? Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.white,
                                  width: 2.0), // Add border
                            ),
                            child: ImageWithDelete(
                              imageData: _additionalImageDataList[index]!,
                              onDelete: () => _deleteImage(index),
                            ),
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.transparent,
                                  width: 2.0), // Add border
                            ),
                          );
                  }),
                ],
              ),
              if (_errorFound)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Main image is required',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.center,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : SizedBox(
                        width: 200,
                        height: 30,
                        child: ElevatedButton(
                          onPressed: addOrUpdateProductImages,
                          child: Text('Next'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF6A994E),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageWithDelete extends StatefulWidget {
  final Uint8List imageData;
  final VoidCallback onDelete;
  final double width;
  final double height;
  final EdgeInsets margin;

  ImageWithDelete({
    required this.imageData,
    required this.onDelete,
    this.width = 80.0,
    this.height = 80.0,
    this.margin = const EdgeInsets.only(right: 8.0),
  });

  @override
  _ImageWithDeleteState createState() => _ImageWithDeleteState();
}

class _ImageWithDeleteState extends State<ImageWithDelete> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDelete, // Hide delete button when long press ends
      child: MouseRegion(
        onEnter: (_) => _setHovering(true),
        onExit: (_) => _setHovering(false),
        child: Center(
          child: Stack(
            children: [
              Container(
                width: widget.width,
                height: widget.height,
                margin: widget.margin,
                child: Image.memory(
                  widget.imageData,
                  width: widget.width,
                  height: widget.height,
                  fit: BoxFit.cover,
                ),
              ),
              if (_isHovering)
                Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: widget.onDelete,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _setHovering(bool isHovering) {
    setState(() {
      _isHovering = isHovering;
    });
  }
}
