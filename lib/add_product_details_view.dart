import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:unshelf_seller/product_summary_view.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/product_viewmodel.dart';

class AddProductDetailsView extends StatelessWidget {
  final String? productId;

  AddProductDetailsView({this.productId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductViewModel(productId: productId),
      child: Consumer<ProductViewModel>(builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
              backgroundColor: Color(0xFF6A994E),
              title: const Text('Product Details')),
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
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      Text(
                        'Enter product details below',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  )
                ]),
                SizedBox(height: 30.0),
                Form(
                  key: viewModel.formKey,
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
                        controller: viewModel.nameController,
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
                        controller: viewModel.descriptionController,
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
                                  controller: viewModel.priceController,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color.fromARGB(
                                        255, 228, 228, 228),
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
                                  controller: viewModel.quantityController,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color.fromARGB(
                                        255, 228, 228, 228),
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
                                  controller: viewModel.expiryDateController,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color.fromARGB(
                                        255, 228, 228, 228),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12.0, horizontal: 12.0),
                                    labelStyle: TextStyle(color: Colors.black),
                                  ),
                                  readOnly: true,
                                  onTap: () =>
                                      viewModel.selectExpiryDate(context),
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
                                  controller: viewModel.discountController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor:
                                        Color.fromARGB(255, 228, 228, 228),
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
                        child: viewModel.isLoading
                            ? CircularProgressIndicator()
                            : SizedBox(
                                width: 200,
                                height: 30,
                                child: ElevatedButton(
                                  onPressed: viewModel.addOrUpdateProduct,
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
      }),
    );
  }
}
