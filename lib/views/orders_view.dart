import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/order_viewmodel.dart';
import 'package:unshelf_seller/views/order_details_view.dart';
import 'package:unshelf_seller/utils/colors.dart';

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  String? _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ordersViewModel =
          Provider.of<OrderViewModel>(context, listen: false);
      ordersViewModel.fetchOrdersFuture;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ordersViewModel = Provider.of<OrderViewModel>(context);

    return Scaffold(
      body: Column(
        children: [
          // Filter Buttons
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildFilterButton('All', ordersViewModel),
                  _buildFilterButton('Pending', ordersViewModel),
                  _buildFilterButton('Processing', ordersViewModel),
                  _buildFilterButton('Ready', ordersViewModel),
                  _buildFilterButton('Completed', ordersViewModel),
                  _buildFilterButton('Cancelled', ordersViewModel),
                ],
              ),
            ),
          ),

          Expanded(
            child: FutureBuilder<void>(
              future: ordersViewModel.fetchOrdersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return Consumer<OrderViewModel>(
                    builder: (context, ordersViewModel, child) {
                      final filteredOrders = ordersViewModel.filteredOrders;

                      if (filteredOrders.isEmpty) {
                        final statusMessages = {
                          'Pending': 'No pending orders for today.',
                          'Processing':
                              'No orders currently being processed today.',
                          'Ready': 'No orders ready for pickup today.',
                          'Completed': 'No completed orders today.',
                          'Cancelled': 'No cancelled orders today.',
                        };

                        // Retrieve message for the current status, or use a default message
                        String message =
                            statusMessages[ordersViewModel.currentStatus] ??
                                'No orders found.';

                        return Center(
                          child: Text(message),
                        );
                      }

                      return ListView.builder(
                        itemCount: ordersViewModel.filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = ordersViewModel.filteredOrders[index];
                          final isDarkBackground = index % 2 == 0;

                          return GestureDetector(
                            onTap: () {
                              ordersViewModel.selectOrder(order.id);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderDetailsView(
                                    orderId: order.id,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              color: isDarkBackground
                                  ? Colors.grey[200]
                                  : Colors.grey[100],
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Middle Section: Order Info
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Order ID: ${order.orderId}',
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4.0),
                                          Text(
                                            order.createdAt
                                                .toDate()
                                                .toLocal()
                                                .toString()
                                                .split(' ')[0],
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 4.0),
                                          Text(
                                            'Status: ${order.status}',
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Right Section: Price and Payment Status
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            fontSize: 18.0,
                                            color: AppColors.palmLeaf,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          children: [
                                            const TextSpan(
                                              text: '\u20B1 ', // Peso symbol
                                              style: TextStyle(
                                                fontFamily: 'Roboto',
                                              ),
                                            ),
                                            TextSpan(
                                              text: '${order.totalPrice}',
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 12.0),
                                        decoration: BoxDecoration(
                                          color: order.isPaid
                                              ? AppColors.palmLeaf
                                              : AppColors.watermelonRed,
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: Text(
                                          order.isPaid ? 'Paid' : 'Unpaid',
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
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String status, OrderViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: TextButton(
        style: TextButton.styleFrom(
          minimumSize: const Size(50, 30),
          backgroundColor: viewModel.currentStatus == status
              ? AppColors.deepMossGreen
              : Colors.grey[200],
          foregroundColor:
              viewModel.currentStatus == status ? Colors.white : Colors.black,
        ),
        onPressed: () {
          setState(() {
            viewModel.currentStatus = status;
            viewModel.filterOrdersByStatus(viewModel.currentStatus);
          });
        },
        child: Text(
          status,
          style: const TextStyle(fontSize: 9.0),
        ),
      ),
    );
  }
}
