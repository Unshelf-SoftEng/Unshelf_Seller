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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<OrderViewModel>(context, listen: false);
      viewModel.fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<OrderViewModel>(context);

    return Scaffold(
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildFilterButton('All', viewModel),
                  _buildFilterButton('Pending', viewModel),
                  _buildFilterButton('Processing', viewModel),
                  _buildFilterButton('Ready', viewModel),
                  _buildFilterButton('Completed', viewModel),
                  _buildFilterButton('Cancelled', viewModel),
                ],
              ),
            ),
          ),

          // Orders List
          Expanded(
            child: Consumer<OrderViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredOrders = viewModel.filteredOrders;

                if (filteredOrders.isEmpty) {
                  final statusMessages = {
                    'Pending': 'No pending orders',
                    'Processing': 'No orders in processing.',
                    'Ready': 'No orders that are ready',
                    'Completed': 'No completed orders.',
                    'Cancelled': 'No cancelled orders',
                  };

                  String message = statusMessages[viewModel.currentStatus] ??
                      'No orders found.';
                  return Center(child: Text(message));
                }

                return ListView.builder(
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    final isDarkBackground = index % 2 == 0;

                    return GestureDetector(
                      onTap: () {
                        viewModel.selectOrder(order.id);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OrderDetailsView(orderId: order.id),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        style: TextStyle(fontFamily: 'Roboto'),
                                      ),
                                      TextSpan(
                                        text:
                                            '${order.totalPrice.toStringAsFixed(2)}',
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
                                    borderRadius: BorderRadius.circular(12.0),
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
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterButton(String status, OrderViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: TextButton(
        style: TextButton.styleFrom(
          minimumSize: const Size(40, 20),
          backgroundColor: viewModel.currentStatus == status
              ? AppColors.darkColor
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
