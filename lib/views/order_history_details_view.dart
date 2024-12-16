import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:unshelf_seller/components/custom_app_bar.dart';
import 'package:unshelf_seller/viewmodels/order_viewmodel.dart';
import 'package:unshelf_seller/utils/colors.dart';
import 'package:unshelf_seller/models/bundle_model.dart';
import 'package:unshelf_seller/models/batch_model.dart';

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
            title: 'Order History Details',
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
                          DateFormat('MMMM dd, yyyy hh:mm a').format(
                              viewModel.selectedOrder!.createdAt.toDate())),

                      if (!viewModel.selectedOrder!.isPaid) ...[
                        _buildDetailCard('Payment Mode', 'Cash'),
                      ] else ...[
                        _buildDetailCard('Payment Mode', 'Paid Online'),
                      ],

                      _buildDetailCard('Subtotal',
                          viewModel.selectedOrder!.subtotal.toStringAsFixed(2)),
                      _buildDetailCard('Discount',
                          viewModel.selectedOrder!.pointsDiscount.toString()),
                      _buildDetailCard(
                          'Total Price',
                          viewModel.selectedOrder!.totalPrice
                              .toStringAsFixed(2)),
                      _buildDetailCard(
                          'Status', viewModel.selectedOrder!.status),
                      const SizedBox(height: 6),

                      _buildDetailCard(
                          'Pickup Time',
                          DateFormat('MMMM dd, yyyy hh:mm a').format(
                              viewModel.selectedOrder!.pickupTime!.toDate())),

                      if (viewModel.currentStatus == 'Cancelled') ...[
                        _buildDetailCard(
                            'Cancelled At',
                            DateFormat('MMMM dd, yyyy hh:mm a').format(viewModel
                                .selectedOrder!.cancelledAt!
                                .toDate())),
                      ],

                      if (viewModel.selectedOrder!.status == 'Ready' ||
                          viewModel.selectedOrder!.status == 'Completed') ...[
                        _buildDetailCard('Pickup Code',
                            viewModel.selectedOrder!.pickupCode!),
                      ],

                      if (viewModel.selectedOrder!.status == 'Completed') ...[
                        _buildDetailCard(
                            'Completed At',
                            DateFormat('MMMM dd, yyyy hh:mm a').format(viewModel
                                .selectedOrder!.completedAt!
                                .toDate())),
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
}
