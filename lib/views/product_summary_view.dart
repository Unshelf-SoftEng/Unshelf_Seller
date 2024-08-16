import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/product_summary_viewmodel.dart';
import 'package:intl/intl.dart';

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

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Header Section
                Card(
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.green.withOpacity(0.2),
                          child: Icon(
                            Icons.shopping_bag,
                            color: Colors.green,
                            size: 30,
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Product Summary',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              'View the product details',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Main Image
                GestureDetector(
                  onTap: () => _showFullImage(viewModel.product!.mainImageUrl),
                  child: Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      color: const Color(0xFF386641),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        viewModel.product!.mainImageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Additional Images
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(4, (index) {
                      if (viewModel.product!.additionalImageUrls != null &&
                          viewModel.product!.additionalImageUrls!.length >
                              index) {
                        return Container(
                          margin: EdgeInsets.only(right: 8.0),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                                color: Colors.white, width: 2.0), // Add border
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              viewModel.product!.additionalImageUrls![index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      } else {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                                color: Colors.grey,
                                width: 2.0), // Placeholder border
                          ),
                          child: Icon(Icons.image_not_supported,
                              color: Colors.grey),
                        );
                      }
                    }),
                  ],
                ),

                const SizedBox(height: 30),

                // Product Details
                _buildProductDetail('Name', viewModel.product!.name),
                _buildProductDetail(
                    'Description', viewModel.product!.description),
                _buildProductDetail('Category', viewModel.product!.category),
                _buildProductDetail('Price', '\$${viewModel.product!.price}'),
                _buildProductDetail(
                    'Quantifier', viewModel.product!.quantifier),
                _buildProductDetail(
                    'Stock', '${viewModel.product!.stock} units'),
                _buildProductDetail(
                  'Expiry Date',
                  DateFormat('yyyy-MM-dd')
                      .format(viewModel.product!.expiryDate.toLocal()),
                ),
                _buildProductDetail(
                    'Discount', '${viewModel.product!.discount}% off'),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper method to build product detail row
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
