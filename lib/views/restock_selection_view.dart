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
        backgroundColor: const Color(0xFF6A994E),
        foregroundColor: const Color(0xFFFFFFFF),
        titleTextStyle: TextStyle(
            color: const Color(0xFFFFFFFF),
            fontSize: 20,
            fontWeight: FontWeight.bold),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Color(0xFF386641),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Container(
            color: Color(0xFFC8DD96),
            height: 4.0,
          ),
        ),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Check if products list is empty
                  if (viewModel.products.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          'No products available for restocking.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: viewModel.products.length,
                        itemBuilder: (context, index) {
                          final product = viewModel.products[index];
                          bool isSelected = viewModel.contain(product);

                          return Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            color: isSelected
                                ? const Color(
                                    0xFF6A994E) // Very green when selected
                                : Colors
                                    .white, // Default white when not selected
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 16.0,
                              ),
                              title: Text(
                                product.product!.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors
                                          .black, // White text when selected
                                ),
                              ),
                              subtitle: Text(
                                'Current Quantity: ${product.stock ?? 0}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected
                                      ? Colors.white70
                                      : Colors.grey[
                                          700], // Lighter text when selected
                                ),
                              ),
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(product.product!.mainImageUrl),
                                radius: 30,
                                backgroundColor: Colors.grey[200],
                              ),
                              trailing: Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.check_circle_outline,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey, // White icon when selected
                                size: 30,
                              ),
                              onTap: () {
                                setState(() {
                                  viewModel.addSelectedProduct(product);
                                });
                              },
                              onLongPress: () {
                                setState(() {
                                  viewModel.removeSelectedProduct(product);
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: viewModel.selectedProducts.isNotEmpty
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RestockDetailsView(),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: viewModel.selectedProducts.isNotEmpty
                            ? const Color(0xFF6A994E)
                            : Colors.grey, // Disabled state color
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
