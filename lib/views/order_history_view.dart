import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/components/custom_app_bar.dart';
import 'package:unshelf_seller/viewmodels/order_viewmodel.dart';
import 'package:unshelf_seller/views/order_history_details_view.dart';
import 'package:unshelf_seller/utils/colors.dart';

class OrderHistoryView extends StatefulWidget {
  const OrderHistoryView({super.key});

  @override
  State<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<OrderViewModel>(context, listen: false);
      viewModel.fetchOrdersHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<OrderViewModel>(context);

    return Scaffold(
      appBar: CustomAppBar(
          title: 'Order History',
          onBackPressed: () {
            Navigator.pop(context);
          }),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 8.0),
              // Title text
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // A row for the filter and sort options
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Filter PopupMenuButton
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: PopupMenuButton<String>(
                        onSelected: (value) {
                          viewModel.currentStatus = value;
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            'All',
                            'Pending',
                            'Processing',
                            'Ready',
                            'Completed',
                            'Cancelled'
                          ].map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(choice),
                            );
                          }).toList();
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.filter_list, size: 20),
                            const SizedBox(width: 4.0),
                            Text(viewModel.currentStatus),
                          ],
                        ),
                      ),
                    ),

                    // Sort Order PopupMenuButton
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: PopupMenuButton<String>(
                        onSelected: (value) {
                          viewModel.sortOrder = value;
                        },
                        itemBuilder: (BuildContext context) {
                          return ['Ascending', 'Descending']
                              .map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(choice),
                            );
                          }).toList();
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.sort, size: 20),
                            const SizedBox(width: 4.0),
                            Text(viewModel.sortOrder),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                                OrderHistoryDetailsView(orderId: order.id),
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
