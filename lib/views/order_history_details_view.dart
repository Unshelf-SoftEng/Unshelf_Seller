import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:unshelf_seller/components/custom_app_bar.dart';
import 'package:unshelf_seller/viewmodels/order_viewmodel.dart';
import 'package:unshelf_seller/utils/colors.dart';

class OrderHistoryDetailsView extends StatefulWidget {
  final String orderId;

  const OrderHistoryDetailsView({super.key, required this.orderId});

  @override
  State<OrderHistoryDetailsView> createState() =>
      _OrderHistoryDetailsViewState();
}

class _OrderHistoryDetailsViewState extends State<OrderHistoryDetailsView> {
  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<OrderViewModel>(context, listen: false);
    viewModel.selectOrder(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderViewModel>(builder: (context, viewModel, child) {
      final order = viewModel.selectedOrder;

      return Scaffold(
        appBar: CustomAppBar(
            title: 'Order Details',
            onBackPressed: () {
              Navigator.pop(context);
            }),
        body: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 10.0),
                child: SingleChildScrollView(
                  // Wrap everything in SingleChildScrollView
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Overview Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey.shade300), // Border color
                          borderRadius:
                              BorderRadius.circular(8), // Rounded corners
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order ID: ${order!.orderId}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Buyer Name: ${order.buyerName}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Order Date: ${DateFormat('yyyy-MM-dd').format(order.createdAt.toDate())}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Price: ₱${order.totalPrice}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                // Box for Order Status
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.palmLeaf,
                                    border: Border.all(
                                      color: Colors.black, // Border color
                                      width: 1.0, // Border width
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    order.status,
                                    style: const TextStyle(
                                      fontSize: 14.0, // Font size for the text
                                      color: Colors.black, // Text color
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                    width: 10), // Space between the boxes

                                // Box for Paid or Not Paid
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: order.isPaid
                                        ? AppColors.palmLeaf
                                        : AppColors.watermelonRed,
                                    border: Border.all(
                                      color: Colors.black, // Border color
                                      width: 1.0, // Border width
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    order.isPaid ? 'Paid' : 'Not Paid',
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      color: Colors
                                          .white, // White text for clarity
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Products List
                      const Text(
                        'Products',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Products List View (no Expanded around it)
                      ListView.builder(
                        itemCount: order.items.length,
                        shrinkWrap:
                            true, // Important for ListView inside scrollable widget
                        physics:
                            NeverScrollableScrollPhysics(), // Disable internal scrolling
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.horizontal(
                                      left: Radius.circular(10)),
                                  child: Image.network(
                                    order.products[index].product!.mainImageUrl,
                                    width: 80, // Reduced the size of the image
                                    height: 80, // Reduced the size of the image
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order.products[index].product!.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                      ],
                                    ),
                                  ),
                                ),
                                // Spacer for right-alignment
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'x ${order.items[index].quantity} ${order.products[index].quantifier}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      // Order Details Section
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      );
    });
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
