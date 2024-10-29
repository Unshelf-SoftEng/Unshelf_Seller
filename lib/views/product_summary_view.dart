import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/product_summary_viewmodel.dart';
import 'package:unshelf_seller/views/add_batch_view.dart';

class ProductSummaryView extends StatefulWidget {
  final String? productId;

  ProductSummaryView({this.productId});

  @override
  _ProductSummaryViewState createState() => _ProductSummaryViewState();
}

class _ProductSummaryViewState extends State<ProductSummaryView> {
  late ProductSummaryViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<ProductSummaryViewModel>(context, listen: false);
    if (widget.productId != null) {
      viewModel.fetchProductData(widget.productId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Summary'),
        backgroundColor: const Color(0xFF6A994E),
        elevation: 1.0,
      ),
      body: Consumer<ProductSummaryViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (viewModel.product == null) {
            return Center(child: Text('No product data available.'));
          }

          final mainImageUrl = viewModel.product!.mainImageUrl;
          final additionalImages = viewModel.product!.additionalImageUrls;

          // Create a list of images to display
          final images = [mainImageUrl]..addAll(additionalImages ?? []);

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Gallery
                _buildImageGallery(images, viewModel),
                const SizedBox(height: 16.0),
                // Product Details
                _buildProductDetail('Name', viewModel.product!.name),
                _buildProductDetail(
                    'Description', viewModel.product!.description),
                _buildProductDetail('Category', viewModel.product!.category),
                const SizedBox(height: 16.0),
                // Batches Section
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
            color: const Color(0xFF386641),
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
                    fit: BoxFit.cover,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '$title:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
          ),
          SizedBox(width: 8.0),
          Expanded(
            flex: 7,
            child: Text(
              value,
              style: TextStyle(fontSize: 16.0, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  // Method to build batches section
  Widget _buildBatchesSection(ProductSummaryViewModel viewModel) {
    final batches = viewModel.batches;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Batches:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
        const SizedBox(height: 8.0),
        if (batches != null && batches.isNotEmpty)
          ListView.builder(
            itemCount: batches.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final batch = batches[index];
              return Card(
                elevation: 2.0,
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  title: Text('Batch ${index + 1}: ${batch.batchNumber}'),
                  subtitle: Text('Quantity: ${batch.stock}'),
                ),
              );
            },
          )
        else
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AddBatchView(productId: widget.productId!)));
            },
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  'No batches available. Tap to add a batch.',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ),
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
        child: Container(
          child: Image.network(imageUrl, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
