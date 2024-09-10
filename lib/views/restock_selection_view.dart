import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/restock_viewmodel.dart';
import 'restock_details_view.dart';

class RestockSelectionView extends StatefulWidget {
  @override
  _RestockSelectionViewState createState() => _RestockSelectionViewState();
}

class _RestockSelectionViewState extends State<RestockSelectionView> {
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
        title: Text('Select Products to Restock'),
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
                      final isSelected =
                          viewModel.selectedProducts.contains(product);

                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text('Current Quantity: ${product.stock}'),
                        trailing: Icon(
                          isSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: isSelected ? Colors.green : Colors.grey,
                        ),
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              viewModel.removeSelectedProduct(product);
                            } else {
                              viewModel.addSelectedProduct(product);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (viewModel.selectedProducts.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RestockDetailsView(),
                        ),
                      );
                    }
                  },
                  child: Text('Next'),
                ),
              ],
            ),
    );
  }
}
