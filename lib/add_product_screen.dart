import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class AddProductScreen extends StatefulWidget {
  final String? productId;
  final String? productName;
  final double? productPrice;

  AddProductScreen({
    this.productId,
    this.productName,
    this.productPrice,
  });

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.productName != null) {
      _productNameController.text = widget.productName!;
    }

    if (widget.productPrice != null) {
      _productPriceController.text = widget.productPrice!.toString();
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

        if (user != null) {
          if (widget.productId == null) {
            // Add new product
            await FirebaseFirestore.instance.collection('products').add({
              'name': _productNameController.text,
              'price': price,
              'seller_id': user.uid,
            });
          } else {
            // Update existing product
            await FirebaseFirestore.instance
                .collection('products')
                .doc(widget.productId)
                .update({
              'name': _productNameController.text,
              'price': price,
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
                decoration: InputDecoration(
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
              SizedBox(height: 20),
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
