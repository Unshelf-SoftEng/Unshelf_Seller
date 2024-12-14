import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/components/custom_app_bar.dart';
import 'package:unshelf_seller/viewmodels/restock_viewmodel.dart';
import 'restock_details_view.dart';
import 'package:unshelf_seller/utils/colors.dart';

class RestockSelectionView extends StatefulWidget {
  const RestockSelectionView({super.key});

  @override
  State<RestockSelectionView> createState() => _RestockSelectionViewState();
}

class _RestockSelectionViewState extends State<RestockSelectionView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<RestockViewModel>(context, listen: false);
      viewModel.fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RestockViewModel>(context);

    return Scaffold(
      appBar: CustomAppBar(
          title: 'Select Products for Restocking',
          onBackPressed: () {
            Navigator.pop(context);
          }),
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
                            color:
                                isSelected ? AppColors.palmLeaf : Colors.white,
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
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                              subtitle: Text(
                                'Current Quantity: ${product.stock}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected
                                      ? Colors.white70
                                      : Colors.grey[700],
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
                                  builder: (context) =>
                                      const RestockDetailsView(),
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
                            : Colors.grey,
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
