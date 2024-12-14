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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<OrderViewModel>();
      viewModel.selectOrder(widget.orderId);
    });
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
                      // Order Overview Card (First Half with Details)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            child: Text(
                              'Order Information',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.palmLeaf,
                              ),
                            ),
                          ),
                          _buildDetailCard('Order ID', order!.orderId),
                          _buildDetailCard('Buyer Name', order.buyerName),
                          _buildDetailCard(
                            'Order Date',
                            DateFormat('MM-dd-yyyy HH:mm')
                                .format(order.createdAt.toDate()),
                          ),
                          _buildDetailCard('Price', '${order.totalPrice}'),
                          _buildDetailCard('Status', order.status),
                          _buildDetailCard(
                              'Paid', order.isPaid ? 'Paid' : 'Not Paid'),
                          _buildDetailCard(
                            'Pickup Time',
                            DateFormat('MM-dd-yyyy HH:mm').format(
                                order.pickupTime?.toDate() ?? DateTime.now()),
                          ),
                          _buildDetailCard(
                              'Pickup Code', order.pickupCode ?? 'N/A'),
                          _buildDetailCard(
                            'Completed At',
                            DateFormat('MM-dd-yyy HH:mm').format(
                                order.completedAt?.toDate() ?? DateTime.now()),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          'Order Items',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.palmLeaf,
                          ),
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
                      const SizedBox(height: 20),
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
            if (title != 'Price')
              Expanded(
                flex: 2,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              )
            else
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
          ],
        ),
      ),
    );
  }
}
