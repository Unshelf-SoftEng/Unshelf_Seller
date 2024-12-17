import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:unshelf_seller/components/custom_app_bar.dart';
import 'package:unshelf_seller/viewmodels/order_viewmodel.dart';
import 'package:unshelf_seller/utils/colors.dart';
import 'package:unshelf_seller/models/bundle_model.dart';
import 'package:unshelf_seller/models/batch_model.dart';

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
                      const SizedBox(height: 10),
                      Text(
                        'Order ID: ${viewModel.selectedOrder!.orderId}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildDetailCard(
                          'Buyer Name', viewModel.selectedOrder!.buyerName),
                      _buildDetailCard(
                          'Order Date',
                          DateFormat('MMMM dd, yyyy hh:mm a').format(viewModel
                              .selectedOrder!.createdAt
                              .toDate()
                              .toLocal())),

                      // _buildDetailCard('Subtotal',
                      //     viewModel.selectedOrder!.subtotal.toStringAsFixed(2)),
                      // _buildDetailCard('Discount',
                      //     viewModel.selectedOrder!.pointsDiscount.toString()),
                      _buildDetailCard(
                          'Total Price',
                          viewModel.selectedOrder!.totalPrice
                              .toStringAsFixed(2)),
                      _buildDetailCard(
                          'Status', viewModel.selectedOrder!.status),
                      const SizedBox(height: 6),

                      if (viewModel.selectedOrder!.status != 'Pending' &&
                          viewModel.selectedOrder!.status != 'Processing') ...[
                        _buildImportantDetailCard(viewModel),
                      ],

                      const SizedBox(height: 10),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Items in Order',
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor),
                        ),
                      ),
                      const SizedBox(height: 10),

                      ListView.builder(
                        itemCount: viewModel.selectedOrder!.items
                            .length, // Use items length here
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final item = viewModel.selectedOrder!.items[index];
                          Widget? leadingImage;
                          BundleModel? bundle;
                          BatchModel? product;

                          // Check if the item is a bundle or a product
                          if (item.isBundle ?? false) {
                            // Fetch bundle information
                            bundle =
                                viewModel.selectedOrder!.bundles!.firstWhere(
                              (bundle) => bundle.id == item.batchId,
                            );
                            leadingImage = bundle.mainImageUrl.isNotEmpty
                                ? Image.network(
                                    bundle.mainImageUrl,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'assets/images/placeholder.png',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  );
                          } else {
                            product = viewModel.selectedOrder!.products!
                                .firstWhere(
                                    (product) =>
                                        product.batchNumber ==
                                        item.batchId // Handle if not found
                                    );

                            leadingImage =
                                product.product!.mainImageUrl.isNotEmpty
                                    ? Image.network(
                                        product.product!.mainImageUrl,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        'assets/images/placeholder.png',
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      );
                          }

                          return Card(
                            elevation: 2,
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(10)),
                                child: leadingImage,
                              ),
                              title: Text(
                                item.isBundle ?? false
                                    ? bundle!.name
                                    : product!.product!.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                'x ${item.quantity} ${item.isBundle ?? false ? '' : product!.quantifier}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Text(
                                '\u20B1 ${item.price!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // Order Details Section
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
                                  builder: (BuildContext dialogContext) {
                                    return AlertDialog(
                                      title: const Text('Cancel Order'),
                                      content: const Text(
                                          'Are you sure you want to cancel this order?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(dialogContext).pop();
                                          },
                                          child: const Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.of(dialogContext).pop();

                                            if (mounted) {
                                              try {
                                                await viewModel.cancelOrder();
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          "Order has been cancelled successfully!"),
                                                      backgroundColor: AppColors
                                                          .primaryColor,
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          "Failed to cancel order: ${e.toString()}"),
                                                      backgroundColor: AppColors
                                                          .warningColor,
                                                    ),
                                                  );
                                                }
                                              }
                                            }
                                          },
                                          child: const Text(
                                            'Yes, Cancel',
                                            style: TextStyle(
                                                color: AppColors.warningColor),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.warningColor,
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
                                showDialog(
                                  context: context,
                                  builder: (BuildContext dialogContext) {
                                    return AlertDialog(
                                      title: const Text('Approve Order?'),
                                      content: const Text(
                                          'Are you sure you want to approve this order?'),
                                      actions: [
                                        // Cancel button
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(dialogContext).pop();
                                          },
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                                color: AppColors.warningColor),
                                          ),
                                        ),
                                        // Confirm button
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop();

                                            if (mounted) {
                                              try {
                                                await viewModel.approveOrder();
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          "Order has been approved successfully!"),
                                                      backgroundColor: AppColors
                                                          .primaryColor,
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          "Failed to approve order: ${e.toString()}"),
                                                      backgroundColor: AppColors
                                                          .warningColor,
                                                    ),
                                                  );
                                                }
                                              }
                                            }
                                          },
                                          child: const Text('Approve'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
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
                                  backgroundColor: AppColors.primaryColor,
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "Failed to fulfill order: ${e.toString()}"),
                                  backgroundColor: AppColors.warningColor,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Complete Order'),
                          onPressed: () {
                            // Show confirmation dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return AlertDialog(
                                  title: const Text('Confirm Order?'),
                                  content: viewModel.selectedOrder!.isPaid
                                      ? Text(
                                          'Are you sure you want to complete this order?')
                                      : Text(
                                          'Confirming order means you have accepted the money from the buyer.'),
                                  actions: [
                                    // Cancel button
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(dialogContext).pop();
                                      },
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(
                                            color: AppColors.warningColor),
                                      ),
                                    ),
                                    // Confirm button
                                    TextButton(
                                      onPressed: () async {
                                        // Add your order completion logic here
                                        Navigator.of(dialogContext).pop();
                                        if (mounted) {
                                          try {
                                            await viewModel.completeOrder();
                                            if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      "Order has been completed!"),
                                                  backgroundColor:
                                                      AppColors.primaryColor,
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      "Failed to complete order: ${e.toString()}"),
                                                  backgroundColor:
                                                      AppColors.warningColor,
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      },
                                      child: const Text('Confirm'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
      );
    });
  }

  Widget _buildDetailCard(String title, String value) {
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
            if (title == 'Price') ...[
              Expanded(
                flex: 2,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                    children: [
                      const TextSpan(
                        text: '\u20B1 ', // Peso symbol
                        style: TextStyle(
                          fontFamily: 'Roboto',
                        ),
                      ),
                      TextSpan(
                        text: value,
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (title == 'Order Date') ...[
              Expanded(
                flex: 2,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
            ] else if (title == 'Pending Payment') ...[
              Expanded(
                flex: 2,
                child: Text(
                  value,
                  style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.warningColor,
                      fontWeight: FontWeight.bold),
                ),
              )
            ] else ...[
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
          ],
        ),
      ),
    );
  }

  Widget _buildImportantDetailCard(viewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0), // Space between boxes
      padding: const EdgeInsets.all(16.0), // Padding around the entire card
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.lightColor, // Border color
          width: 1.0, // Border width
        ),
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (viewModel.selectedOrder!.status == 'Ready') ...[
            _buildDetailRow(
                'Pickup Code', viewModel.selectedOrder!.pickupCode!),
            if (viewModel.selectedOrder!.pickupTime != null) ...[
              _buildDetailRow(
                'Pickup Time',
                DateFormat('MMMM dd, yyyy hh:mm a').format(
                  viewModel.selectedOrder!.pickupTime!.toDate(),
                ),
              ),
            ],
            if (!viewModel.selectedOrder!.isPaid) ...[
              _buildDetailRow(
                'Pending Payment',
                viewModel.selectedOrder!.totalPrice.toStringAsFixed(2),
              ),
            ],
          ] else if (viewModel.selectedOrder!.status == 'Completed') ...[
            _buildDetailRow(
              'Completed At',
              DateFormat('MMMM dd, yyyy hh:mm a').format(
                viewModel.selectedOrder!.completedAt!.toDate(),
              ),
            ),
          ] else if (viewModel.selectedOrder!.status == 'Cancelled') ...[
            _buildDetailRow(
              'Cancelled At',
              viewModel.selectedOrder?.cancelledAt != null
                  ? DateFormat('MMMM dd, yyyy hh:mm a').format(
                      viewModel.selectedOrder!.cancelledAt!.toDate(),
                    )
                  : 'N/A',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 4.0), // Space between title and value
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: 'Roboto',
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Roboto',
              ),
              overflow: TextOverflow.ellipsis, // In case text overflows
              textAlign: TextAlign.end, // Align value to the right
            ),
          ),
        ],
      ),
    );
  }
}
