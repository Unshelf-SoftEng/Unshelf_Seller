import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

class AddProductDetailsView extends StatefulWidget {
  final String? productId;

  AddProductDetailsView({this.productId});

  @override
  _AddProductDetailsViewState createState() => _AddProductDetailsViewState();
}

class _AddProductDetailsViewState extends State<AddProductDetailsView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

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
      _nameController.text = productData['name'];
      _priceController.text = productData['price'].toString();
      _quantityController.text = productData['quantity'].toString();
      _descriptionController.text = productData['description'];
      _expiryDateController.text = productData['expiry_date'];
      _discountController.text = productData['voucher_percentage'].toString();
    }
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
        int discount;
        try {
          price = double.parse(_priceController.text);
          discount = int.tryParse(_discountController.text) ?? 0;
        } catch (e) {
          throw FormatException('Invalid price format');
        }

        if (user != null) {
          if (widget.productId == null) {
            // Add new product
            await FirebaseFirestore.instance.collection('products').add({
              'seller_id': user.uid,
              'name': _nameController.text,
              'description': _descriptionController.text,
              'price': price,
              'quantity': int.tryParse(_quantityController.text) ?? 0,
              'expiry_date': _expiryDateController.text,
              'discount': discount,
            });
          } else {
            // Update existing product
            await FirebaseFirestore.instance
                .collection('products')
                .doc(widget.productId)
                .update({
              'name': _nameController.text,
              'price': price,
              'quantity': int.tryParse(_quantityController.text) ?? 0,
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
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _expiryDateController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6A994E),
        title: Text(widget.productId == null ? 'Add Product' : 'Edit Product'),
      ),
      body: Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
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
                      '1/2',
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
                  Text('Product Details',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(
                    'Enter product details',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              )
            ]),
            SizedBox(height: 30.0),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Name',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromARGB(255, 228, 228, 228),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      labelStyle: const TextStyle(color: Colors.black),
                      errorStyle: const TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a product name';
                      }
                      return null;
                    },
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromARGB(255, 228, 228, 228),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 12.0),
                      labelStyle: const TextStyle(color: Colors.black),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Price',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            TextFormField(
                              controller: _priceController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    const Color.fromARGB(255, 228, 228, 228),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 12.0),
                                labelStyle: TextStyle(color: Colors.black),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*$')),
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
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quantity',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            TextFormField(
                              controller: _quantityController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    const Color.fromARGB(255, 228, 228, 228),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 12.0),
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a quantity';
                                }
                                return null;
                              },
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Expiry Date',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            TextFormField(
                              controller: _expiryDateController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    const Color.fromARGB(255, 228, 228, 228),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 12.0),
                                labelStyle: TextStyle(color: Colors.black),
                              ),
                              readOnly: true,
                              onTap: () => _selectExpiryDate(context),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select an expiry date';
                                }
                                return null;
                              },
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Discount (%)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            TextFormField(
                              controller: _discountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color.fromARGB(255, 228, 228, 228),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 12.0),
                                labelStyle: TextStyle(color: Colors.black),
                              ),
                              validator: (value) {
                                final intValue = int.tryParse(value ?? '');
                                if (intValue == null ||
                                    intValue < 0 ||
                                    intValue > 100) {
                                  return 'Please enter a valid percentage between 0 and 100';
                                }
                                return null;
                              },
                              inputFormatters: [
                                FilteringTextInputFormatter
                                    .digitsOnly, // Allows only digits
                              ],
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Align(
                    alignment: Alignment.center,
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : SizedBox(
                            width: 200,
                            height: 30,
                            child: ElevatedButton(
                              onPressed: addOrUpdateProduct,
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
          ],
        ),
      ),
    );
  }
}
