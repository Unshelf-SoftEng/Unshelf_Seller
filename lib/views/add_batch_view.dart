import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/components/custom_button.dart';
import 'package:unshelf_seller/viewmodels/batch_viewmodel.dart';
import 'package:unshelf_seller/components/custom_app_bar.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Batch Number (optional)'),
                controller: viewModel.batchNumberController,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Expiry Date'),
                readOnly: true,
                controller: TextEditingController(
                  text: viewModel.expiryDate != null
                      ? "${viewModel.expiryDate!.day}/${viewModel.expiryDate!.month}/${viewModel.expiryDate!.year}"
                      : '',
                ),
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
                    return 'Expiry date is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price (₱)'),
                keyboardType: TextInputType.number,
                controller: viewModel.priceController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Price is required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                controller: viewModel.stockController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Stock is required';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid stock quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Quantifier'),
                controller: viewModel.quantifierController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Quantifier is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Discount (%)'),
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
              const SizedBox(height: 16.0),
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
