import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
        appBar: AppBar(
          title: const Text('Order Details'),
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
        ),
        body: viewModel.isLoading
            ? Center(child: CircularProgressIndicator())
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
                              style: TextStyle(
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
                      if (order.status == 'Ready') ...[
                        _buildDetailRow('Pickup Code', order.pickupCode!),
                        if (order.pickupTime != null) ...[
                          _buildDetailRow(
                              'Pickup Time',
                              DateFormat('yyyy-MM-dd HH:mm')
                                  .format(order.pickupTime!.toDate())),
                        ],
                        if (!order.isPaid) ...[
                          _buildDetailRow(
                              'Payment', order.totalPrice.toString()),
                        ],
                      ] else if (order.status == 'Completed') ...[
                        _buildDetailRow(
                            'Completed At',
                            DateFormat('yyyy-MM-dd HH:mm')
                                .format(order.completedAt!.toDate())),
                      ] else if (order.status == 'Cancelled') ...[
                        _buildDetailRow(
                            'Cancelled At',
                            DateFormat('yyyy-MM-dd HH:mm')
                                .format(order.cancelledAt!.toDate())),
                      ],
                    ],
                  ),
                ),
              ),
        bottomNavigationBar: Card(
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
                if (order!.status == 'Pending')
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
                          backgroundColor: Colors.red,
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
                                backgroundColor: AppColors.middleGreenYellow,
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
                          backgroundColor: const Color(0xFFA7C957),
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
                if (order.status == 'Processing')
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        print('Fulfilling order');
                        await viewModel.fulfillOrder();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Order marked as ready for pickup!"),
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
                if (order.status == 'Ready')
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
                      backgroundColor: const Color(0xFFA7C957),
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
