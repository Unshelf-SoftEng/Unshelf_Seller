import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/components/custom_app_bar.dart';
import 'package:unshelf_seller/models/product_model.dart';
import 'package:unshelf_seller/viewmodels/product_summary_viewmodel.dart';
import 'package:unshelf_seller/views/add_batch_view.dart';
import 'package:unshelf_seller/utils/colors.dart';

class ProductDetailsView extends StatefulWidget {
  final String productId;
  final bool? isNew;

  const ProductDetailsView(
      {super.key, required this.productId, this.isNew = false});

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    final viewModel =
        Provider.of<ProductSummaryViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchProductData(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: 'Product Details',
          onBackPressed: () {
            Navigator.pop(context);
          }),
      body: Consumer<ProductSummaryViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.product != null &&
              widget.isNew == true &&
              !_dialogShown) {
            _dialogShown = true;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showAddBatchDialog(viewModel.product!);
            });
          }

          if (viewModel.product == null) {
            return const Center(child: Text('No product data available.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Image.network(
                  viewModel.product!.mainImageUrl,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),

                const SizedBox(height: 16.0),
                _buildProductDetail('Name', viewModel.product!.name),
                _buildProductDetail(
                    'Description', viewModel.product!.description),
                _buildProductDetail('Category', viewModel.product!.category),
                const SizedBox(height: 5.0),
                // Batches Section
                _buildSectionHeader('Batches'),
                _buildBatchesSection(viewModel),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Consumer<ProductSummaryViewModel>(
        builder: (context, viewModel, child) {
          return FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddBatchView(
                    product: viewModel.product!,
                  ),
                ),
              );

              if (result == true) {
                viewModel.fetchProductData(widget.productId);
              }
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label:
                const Text('Add Batch', style: TextStyle(color: Colors.white)),
            backgroundColor: AppColors.primaryColor,
          );
        },
      ),
    );
  }

  // Method to build product detail row
  Widget _buildProductDetail(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header for sections
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  // Method to build batches section
  Widget _buildBatchesSection(ProductSummaryViewModel viewModel) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Card(
            elevation: 2.0,
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'No batches available.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey[600]),
                    textAlign:
                        TextAlign.center, // Centers text within the column
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddBatchDialog(ProductModel product) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Batch',
              style: TextStyle(color: AppColors.primaryColor)),
          content: const Text(
            'Products need to have batches to be listed.\nDo you want to add a batch now?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Skip',
                style: TextStyle(color: AppColors.primaryColor),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog first
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddBatchView(product: product),
                  ),
                );

                if (result == true) {
                  if (mounted) {
                    final viewModel = Provider.of<ProductSummaryViewModel>(
                        context,
                        listen: false);
                    viewModel.fetchProductData(product.id);
                  }
                }
              },
              child: const Text(
                'Add Batch',
                style: TextStyle(color: AppColors.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
