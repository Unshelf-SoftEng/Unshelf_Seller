import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/components/custom_button.dart';
import 'package:unshelf_seller/viewmodels/batch_viewmodel.dart';
import 'package:unshelf_seller/components/custom_app_bar.dart';
import 'package:unshelf_seller/utils/colors.dart';
import 'package:unshelf_seller/models/product_model.dart';

class AddBatchView extends StatelessWidget {
  final ProductModel product;
  final _formKey = GlobalKey<FormState>();

  AddBatchView({required this.product});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<BatchViewModel>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Enter Batch Details',
        onBackPressed: () {
          viewModel.clearData();
          Navigator.pop(context);
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProductHeader(product),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Batch Number (Optional)',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.lightColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: AppColors.lightColor, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.warningColor),
                      ),
                    ),
                    controller: viewModel.batchNumberController,
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Expiration Date',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.lightColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: AppColors.lightColor, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.warningColor),
                      ),
                    ),
                    controller: TextEditingController(
                      text: viewModel.expiryDate != null
                          ? "${viewModel.expiryDate!.month}-${viewModel.expiryDate!.day}-${viewModel.expiryDate!.year}"
                          : '',
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        viewModel.expiryDate = date;
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Expiration date is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.lightColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: AppColors.lightColor, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.warningColor),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    controller: viewModel.priceController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Price is required';
                      }
                      if (double.tryParse(value) == null ||
                          double.parse(value) <= 0) {
                        return 'Please enter a valid price';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Stock',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.lightColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: AppColors.lightColor, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.warningColor),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    controller: viewModel.stockController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Stock is required';
                      }
                      if (int.tryParse(value) == null ||
                          int.parse(value) <= 0) {
                        return 'Please enter a valid stock quantity';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Quantifier',
                      hintText: 'e.g. kilogram, can, pack',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.lightColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: AppColors.lightColor, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.warningColor),
                      ),
                    ),
                    controller: viewModel.quantifierController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Quantifier is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Discount (%)',
                      hintText: 'e.g. 10 for 10%, 0 for no discount',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.lightColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: AppColors.lightColor, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.warningColor),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    controller: viewModel.discountController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Discount is required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid discount percentage';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  CustomButton(
                      text: 'Add Product Batch',
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          // Call the ViewModel method to add the batch
                          await viewModel.addBatch(product.id);

                          if (!viewModel.isLoading) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Product batch added successfully!')),
                            );
                            viewModel.clearData();
                            Navigator.pop(context, true);
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Please fill in all required fields')),
                          );
                        }
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductHeader(ProductModel product) {
    return Column(
      children: [
        const Text(
          'Adding Batch for:',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          product.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const Divider(thickness: 1.0, height: 20.0),
        Image.network(
          product.mainImageUrl,
          height: 150,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ],
    );
  }
}
