import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/restock_viewmodel.dart';
import 'package:intl/intl.dart';

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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: viewModel.selectedProducts.length,
              itemBuilder: (context, index) {
                final product = viewModel.selectedProducts[index];

                return ListTile(
                  title: Text(product.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration:
                            InputDecoration(labelText: 'Restock Quantity'),
                        onChanged: (value) {
                          final quantity = int.tryParse(value) ?? 0;
                          product.stock = quantity;
                        },
                      ),
                      SizedBox(height: 10),
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
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today),
                            SizedBox(width: 8),
                            Text(
                              product.expiryDate == null
                                  ? 'Select Expiry Date'
                                  : DateFormat('yyyy-MM-dd')
                                      .format(product.expiryDate),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final productsToRestock = viewModel.selectedProducts
                  .where((product) => product.stock > 0)
                  .toList();
              await viewModel.batchRestock(productsToRestock);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: Text('Submit Restock'),
          ),
          if (viewModel.error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error: ${viewModel.error}',
                  style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }
}
