import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/components/custom_button.dart';
import 'package:unshelf_seller/viewmodels/batch_viewmodel.dart';
import 'package:unshelf_seller/components/custom_app_bar.dart';
import 'package:unshelf_seller/utils/colors.dart';

class AddBatchView extends StatelessWidget {
  final String productId;
  final _formKey = GlobalKey<FormState>();

  AddBatchView({required this.productId});

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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Batch Number (Optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
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
                    color: AppColors.watermelonRed,
                    fontSize: 10,
                  ),
                ),
                controller: viewModel.batchNumberController,
              ),
              const SizedBox(height: 20.0),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Expiration Date',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
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
                    color: AppColors.watermelonRed,
                    fontSize: 10,
                  ),
                ),
                controller: TextEditingController(
                  text: viewModel.expiryDate != null
                      ? "${viewModel.expiryDate!.day}/${viewModel.expiryDate!.month}/${viewModel.expiryDate!.year}"
                      : '',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Expiration date is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Price',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
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
                    color: AppColors.watermelonRed,
                    fontSize: 10,
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
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Stock',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
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
                    color: AppColors.watermelonRed,
                    fontSize: 10,
                  ),
                ),
                keyboardType: TextInputType.number,
                controller: viewModel.stockController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Stock is required';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid stock quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Quantifier',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
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
                    color: AppColors.watermelonRed,
                    fontSize: 10,
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
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Discount (%)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
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
                    color: AppColors.watermelonRed,
                    fontSize: 10,
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
                      await viewModel.addBatch(productId);

                      if (!viewModel.isLoading) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Product batch added successfully!')),
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
      ),
    );
  }
}
