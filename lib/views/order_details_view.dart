import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:unshelf_seller/components/custom_app_bar.dart';
import 'package:unshelf_seller/viewmodels/order_viewmodel.dart';
import 'package:unshelf_seller/utils/colors.dart';

class OrderDetailsView extends StatefulWidget {
  final String orderId;

  const OrderDetailsView({super.key, required this.orderId});

  @override
  State<OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<OrderViewModel>(context, listen: false);
      viewModel.selectOrder(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderViewModel>(builder: (context, viewModel, child) {
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
                              'Order ID: ${viewModel.selectedOrder!.orderId}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Buyer Name: ${viewModel.selectedOrder!.buyerName}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Order Date: ${DateFormat('MM-dd-yyyy').format(viewModel.selectedOrder!.createdAt.toDate())}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 6),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.grey[700],
                                  fontFamily: GoogleFonts.jost().fontFamily,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Total Price: ',
                                  ),
                                  const TextSpan(
                                    text: '\u20B1 ',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                  TextSpan(
                                    text: viewModel.selectedOrder!.totalPrice
                                        .toStringAsFixed(2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4.0, horizontal: 12.0),
                                  decoration: BoxDecoration(
                                    color: AppColors.middleGreenYellow,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Text(
                                    viewModel.selectedOrder!.status,
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4.0, horizontal: 12.0),
                                  decoration: BoxDecoration(
                                    color: viewModel.selectedOrder!.isPaid
                                        ? AppColors.palmLeaf
                                        : AppColors.watermelonRed,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Text(
                                    viewModel.selectedOrder!.isPaid
                                        ? 'Paid'
                                        : 'Unpaid',
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Items in Order',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.palmLeaf,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      ListView.builder(
                        itemCount: viewModel.selectedOrder!.items.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 2,
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(10)),
                                child: Image.network(
                                  viewModel.selectedOrder!.products[index]
                                      .product!.mainImageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                viewModel.selectedOrder!.products[index]
                                    .product!.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                'x ${viewModel.selectedOrder!.items[index].quantity} ${viewModel.selectedOrder!.products[index].quantifier}',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        },
                      ),
                      // Order Details Section
                      if (viewModel.selectedOrder!.status == 'Ready') ...[
                        _buildDetailRow('Pickup Code',
                            viewModel.selectedOrder!.pickupCode!),
                        if (viewModel.selectedOrder!.pickupTime != null) ...[
                          _buildDetailRow(
                              'Pickup Time',
                              DateFormat('yyyy-MM-dd HH:mm').format(viewModel
                                  .selectedOrder!.pickupTime!
                                  .toDate())),
                        ],
                        if (!viewModel.selectedOrder!.isPaid) ...[
                          _buildDetailRow('Payment',
                              viewModel.selectedOrder!.totalPrice.toString()),
                        ],
                      ] else if (viewModel.selectedOrder!.status ==
                          'Completed') ...[
                        _buildDetailRow(
                            'Completed At',
                            DateFormat('yyyy-MM-dd HH:mm').format(viewModel
                                .selectedOrder!.completedAt!
                                .toDate())),
                      ] else if (viewModel.selectedOrder!.status ==
                          'Cancelled') ...[
                        _buildDetailRow(
                            'Cancelled At',
                            DateFormat('yyyy-MM-dd HH:mm').format(viewModel
                                .selectedOrder!.cancelledAt!
                                .toDate())),
                      ],
                    ],
                  ),
                ),
              ),
        bottomNavigationBar: viewModel.isLoading
            ? null
            : Card(
                elevation: 8,
                margin: EdgeInsets.zero,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (viewModel.selectedOrder!.status == 'Pending')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Cancel Order'),
                                      content: const Text(
                                          'Are you sure you want to cancel this order?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close dialog
                                          },
                                          child: const Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            try {
                                              await viewModel.cancelOrder();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      "Order has been canceled successfully."),
                                                  backgroundColor:
                                                      AppColors.watermelonRed,
                                                ),
                                              );
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      "Failed to cancel order: ${e.toString()}"),
                                                  backgroundColor:
                                                      AppColors.watermelonRed,
                                                ),
                                              );
                                            }
                                            Navigator.of(context)
                                                .pop(); // Close dialog
                                          },
                                          child: const Text('Yes, Cancel'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.watermelonRed,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Cancel Order'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  await viewModel.approveOrder();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "Order has been approved successfully!"),
                                      backgroundColor:
                                          AppColors.middleGreenYellow,
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Failed to approve order: ${e.toString()}"),
                                      backgroundColor: AppColors.watermelonRed,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.middleGreenYellow,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Approve Order'),
                            ),
                          ],
                        ),
                      if (viewModel.selectedOrder!.status == 'Processing')
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              await viewModel.fulfillOrder();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Order marked as ready for pickup!"),
                                  backgroundColor: AppColors.middleGreenYellow,
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "Failed to fulfill order: ${e.toString()}"),
                                  backgroundColor: AppColors.watermelonRed,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA7C957),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Mark as Ready'),
                        ),
                      if (viewModel.selectedOrder!.status == 'Ready')
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              await viewModel.completeOrder();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Order has been completed!"),
                                  backgroundColor: AppColors.middleGreenYellow,
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "Failed to complete order: ${e.toString()}"),
                                  backgroundColor: AppColors.watermelonRed,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.middleGreenYellow,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Complete Order'),
                        ),
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

          // Conditional for Price label
          if (label == 'Payment')
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[700],
                  fontFamily: GoogleFonts.jost().fontFamily,
                ),
                children: [
                  const TextSpan(
                    text: '\u20B1 ', // PHP symbol
                    style: TextStyle(
                      fontFamily: 'Roboto',
                    ),
                  ),
                  TextSpan(
                    text: value,
                  ),
                ],
              ),
            )
          else
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
