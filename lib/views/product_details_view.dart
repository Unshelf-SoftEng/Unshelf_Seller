import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/components/custom_app_bar.dart';
import 'package:unshelf_seller/components/custom_button.dart';
import 'package:unshelf_seller/viewmodels/product_summary_viewmodel.dart';
import 'package:unshelf_seller/views/add_batch_view.dart';
import 'package:unshelf_seller/views/edit_batch_view.dart';
import 'package:unshelf_seller/utils/colors.dart';

class ProductDetailsView extends StatefulWidget {
  final String productId;

  ProductDetailsView({required this.productId});

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
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

          if (viewModel.product == null) {
            return const Center(child: Text('No product data available.'));
          }

          final mainImageUrl = viewModel.product!.mainImageUrl;
          final additionalImages = viewModel.product!.additionalImageUrls;

          // Create a list of images to display
          final images = [mainImageUrl, ...?additionalImages];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Gallery
                _buildImageGallery(images, viewModel),
                const SizedBox(height: 16.0),
                _buildProductDetail('Name', viewModel.product!.name),
                _buildProductDetail(
                    'Description', viewModel.product!.description),
                _buildProductDetail('Category', viewModel.product!.category),
                const SizedBox(height: 16.0),
                // Batches Section
                _buildSectionHeader('Batches'),
                _buildBatchesSection(viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  // Method to build the image gallery
  Widget _buildImageGallery(
      List<String> images, ProductSummaryViewModel viewModel) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: PageView.builder(
            controller: viewModel.pageController,
            itemCount: images.length,
            onPageChanged: viewModel.onPageChanged,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _showFullImage(images[index]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    images[index],
                    width: 200,
                    height: 200,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8.0),
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(images.length, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              width: 8.0,
              height: 8.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    viewModel.currentPage == index ? Colors.black : Colors.grey,
              ),
            );
          }),
        ),
      ],
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
          color: AppColors.palmLeaf,
        ),
      ),
    );
  }

  // Method to build batches section
  Widget _buildBatchesSection(ProductSummaryViewModel viewModel) {
    final batches = viewModel.batches;

    return Column(
      children: [
        if (batches != null && batches.isNotEmpty)
          ListView.builder(
            itemCount: batches.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final batch = batches[index];
              return Card(
                elevation: 2.0,
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display batch number directly
                      Text(
                        'Batch Number: ${batch.batchNumber}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, // Spread text and buttons
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Quantity: ${batch.stock}'),
                                Text(
                                    'Price: ₱${batch.price.toStringAsFixed(2)}'), // Display price with 2 decimal points
                                Text(
                                    'Expiry Date: ${DateFormat('MM-dd-yyyy').format(batch.expiryDate)}'), // Formatted expiry date
                              ],
                            ),
                          ),
                          // Icons for editing and deleting
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Color(0xFF6A994E)),
                                onPressed: () async {
                                  final editResult = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditBatchView(
                                        batchNumber: batch.batchNumber,
                                      ),
                                    ),
                                  );

                                  if (editResult == true) {
                                    viewModel
                                        .fetchProductData(widget.productId!);
                                  }
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  // Implement delete functionality
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Batch'),
                                      content: const Text(
                                          'Are you sure you want to delete this batch?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            viewModel
                                                .deleteBatch(batch.batchNumber);
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          },
                                          child: const Text('Yes'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          },
                                          child: const Text('No'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        else
          GestureDetector(
            onTap: () async {
              final editResult = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddBatchView(
                    productId: widget.productId,
                  ),
                ),
              );

              if (editResult == true) {
                viewModel.fetchProductData(widget.productId);
              }
            },
            child: SizedBox(
              width: double.infinity, // Makes the Card take full screen width
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
                    crossAxisAlignment: CrossAxisAlignment
                        .center, // Center the icon and text horizontally
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: 40,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'No batches available. Tap to add a batch.',
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
          ),
        if (batches != null && batches.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: CustomButton(
              text: 'Add Batch',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddBatchView(productId: viewModel.product!.id),
                  ),
                );

                if (result == true) {
                  // Refresh data
                  viewModel.fetchProductData(widget.productId!);
                }
              },
            ),
          ),
      ],
    );
  }

  // Method to show full image on tap
  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Image.network(imageUrl, fit: BoxFit.cover),
      ),
    );
  }
}
