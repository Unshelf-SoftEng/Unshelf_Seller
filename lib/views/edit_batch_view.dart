import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/add_batch_viewmodel.dart';
import 'package:intl/intl.dart';

class EditBatchView extends StatefulWidget {
  final String batchNumber;

  const EditBatchView({required this.batchNumber});

  @override
  _EditBatchViewState createState() => _EditBatchViewState();
}

class _EditBatchViewState extends State<EditBatchView> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to fetch data after the initial build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AddBatchViewModel>(context, listen: false)
          .fetchBatch(widget.batchNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AddBatchViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Batch'),
        backgroundColor: const Color(0xFF6A994E),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Batch Number (optional)'),
                    onChanged: (value) => viewModel.batchNumber = value,
                    controller: viewModel.batchNumberController,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Expiry Date'),
                    readOnly: true,
                    controller: viewModel.expiryDateController,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );

                      if (date != null) {
                        final formattedDate =
                            DateFormat('MM-dd-yyyy').format(date);
                        viewModel.expiryDateController.text = formattedDate;
                        viewModel.expiryDate = date;
                        FocusScope.of(context).unfocus();
                      }
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Price (₱)'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) =>
                        viewModel.price = double.tryParse(value),
                    controller: viewModel.priceController,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Stock'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => viewModel.stock = int.tryParse(value),
                    controller: viewModel.stockController,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Quantifier'),
                    onChanged: (value) => viewModel.quantifier = value,
                    controller: viewModel.quantifierController,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Discount (%)'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) =>
                        viewModel.discount = int.tryParse(value),
                    controller: viewModel.discountController,
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      await viewModel.updateBatch();
                      if (!viewModel.isLoading) {
                        Navigator.pop(context, true);
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
