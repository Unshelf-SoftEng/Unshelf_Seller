import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/restock_viewmodel.dart';

class BatchRestockView extends StatefulWidget {
  @override
  _BatchRestockViewState createState() => _BatchRestockViewState();
}

class _BatchRestockViewState extends State<BatchRestockView> {
  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<RestockViewModel>(context, listen: false);
    viewModel.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RestockViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Batch Restock'),
        backgroundColor: Color(0xFF6A994E),
      ),
      body: viewModel.isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.products.length,
                    itemBuilder: (context, index) {
                      final product = viewModel.products[index];
                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text('Current Quantity: ${product.stock}'),
                        trailing: SizedBox(
                          width: 100,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final quantity = int.tryParse(value) ?? 0;
                              product.stock = quantity;
                            },
                            decoration:
                                InputDecoration(labelText: 'Restock Qty'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final productsToRestock = viewModel.products
                        .where((product) => product.stock > 0)
                        .toList();
                    await viewModel.batchRestock(productsToRestock);
                  },
                  child: Text('Restock'),
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
