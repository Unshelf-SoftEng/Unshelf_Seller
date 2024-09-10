import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/restock_viewmodel.dart';

class RestockDetailsView extends StatefulWidget {
  @override
  _RestockDetailsViewState createState() => _RestockDetailsViewState();
}

class _RestockDetailsViewState extends State<RestockDetailsView> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RestockViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Restock Details'),
        backgroundColor: Color(0xFF6A994E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: viewModel.selectedProducts.length,
                itemBuilder: (context, index) {
                  final product = viewModel.selectedProducts[index];

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Restock Quantity',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 12),
                            ),
                            onChanged: (value) {
                              final quantity = int.tryParse(value) ?? 0;
                              product.stock = quantity;
                            },
                          ),
                          SizedBox(height: 16),
                          GestureDetector(
                            onTap: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  product.expiryDate = pickedDate;
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey[200],
                                border: Border.all(color: Colors.grey[400]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      color: Colors.grey[600]),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      product.expiryDate != null
                                          ? 'Expiry Date: ${DateFormat.yMMMd().format(product.expiryDate!)}'
                                          : 'Select Expiry Date',
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final productsToRestock = viewModel.selectedProducts
                    .where((product) => product.stock > 0)
                    .toList();
                await viewModel.batchRestock(productsToRestock);
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Color(0xFF6A994E),
              ),
              child: Text(
                'Submit Restock',
                style: TextStyle(fontSize: 18),
              ),
            ),
            if (viewModel.error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  'Error: ${viewModel.error}',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
