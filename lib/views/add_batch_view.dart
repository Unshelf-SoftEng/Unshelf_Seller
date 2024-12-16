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
            const SizedBox(height: 16.0),
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
                  const SizedBox(height: 15.0),
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
                  const SizedBox(height: 15.0),
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
                        return 'Please enter price of the batch';
                      }
                      if (double.tryParse(value) == null ||
                          double.parse(value) <= 0) {
                        return 'Please enter a valid price';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15.0),
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
                        return 'Please enter stock quantity';
                      }
                      if (int.tryParse(value) == null ||
                          int.parse(value) <= 0) {
                        return 'Please enter a valid stock quantity';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15.0),
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
                  const SizedBox(height: 15.0),
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
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid discount percentage';
                      }
                      if (int.parse(value) < 0 || int.parse(value) > 100) {
                        return 'Discount percentage must be between 0 and 100';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15.0),
                  CustomButton(
                      text: 'Add Product Batch',
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          // Call the ViewModel method to add the batch
                          bool isSuccessful =
                              await viewModel.addBatch(product.id);

                          if (isSuccessful) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Product batch added successfully!')),
                            );
                            viewModel.clearData();
                            Navigator.pop(context, true);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'An error occurred. Please try again later')),
                            );
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product header section
        Row(
          children: [
            const Text(
              'Batch Details for:',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 8.0), // Space between label and product name
            Expanded(
              child: Text(
                product.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis, // Handles long product names
                maxLines: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0), // Adds space after the header

        // Product image with rounded corners for a modern look
        ClipRRect(
          borderRadius:
              BorderRadius.circular(12.0), // Rounded corners for the image
          child: Image.network(
            product.mainImageUrl,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 10.0),
      ],
    );
  }
}
