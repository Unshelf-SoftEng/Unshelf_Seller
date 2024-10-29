import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/add_batch_viewmodel.dart';

class EditBatchView extends StatelessWidget {
  final String productId;

  const EditBatchView({required this.productId});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AddBatchViewModel>(context);
    viewModel.fetchBatch(productId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Batch'),
        backgroundColor: const Color(0xFF6A994E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              decoration:
                  const InputDecoration(labelText: 'Batch Number (optional)'),
              onChanged: (value) => viewModel.batchNumber = value,
              initialValue: viewModel.batchNumber,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Expiry Date'),
              readOnly: true, // Set this to true to prevent keyboard popup
              controller: TextEditingController(
                text: viewModel.expiryDate != null
                    ? "${viewModel.expiryDate!.day}/${viewModel.expiryDate!.month}/${viewModel.expiryDate!.year}"
                    : '',
              ),
              initialValue: viewModel.expiryDate != null
                  ? "${viewModel.expiryDate!.day}/${viewModel.expiryDate!.month}/${viewModel.expiryDate!.year}"
                  : '',
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
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              onChanged: (value) => viewModel.price = double.tryParse(value),
              initialValue: viewModel.price?.toString(),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Stock'),
              keyboardType: TextInputType.number,
              onChanged: (value) => viewModel.stock = int.tryParse(value),
              initialValue: viewModel.stock?.toString(),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Quantifier'),
              onChanged: (value) => viewModel.quantifier = value,
              initialValue: viewModel.quantifier,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Discount'),
              keyboardType: TextInputType.number,
              onChanged: (value) => viewModel.discount = int.tryParse(value),
              initialValue: viewModel.discount?.toString(),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await viewModel.addBatch(productId);
                if (!viewModel.isLoading) {
                  Navigator.pop(context);
                }
              },
              child: viewModel.isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Update Product Batch'),
            ),
          ],
        ),
      ),
    );
  }
}
