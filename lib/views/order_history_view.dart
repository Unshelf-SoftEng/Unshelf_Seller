import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/order_viewmodel.dart';
import 'package:unshelf_seller/views/order_details_view.dart';
import 'package:unshelf_seller/utils/colors.dart';

class OrderHistoryView extends StatefulWidget {
  @override
  _OrderHistoryViewState createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> {
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
      appBar: AppBar(
        title: Text('View Order History'),
        backgroundColor: const Color(0xFF6A994E),
        foregroundColor: const Color(0xFFFFFFFF),
        titleTextStyle: TextStyle(
          color: const Color(0xFFFFFFFF),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF386641)),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Container(color: Color(0xFFC8DD96), height: 4.0),
        ),
      ),
      body: Column(
        children: [
          // Filter Buttons
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            color: Colors.grey[200],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
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

          // Orders List
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
                          'Pending': 'No pending orders',
                          'Processing': 'No orders in processing.',
                          'Ready': 'No orders that are ready',
                          'Completed': 'No completed orders.',
                          'Cancelled': 'No cancelled orders',
                        };

                        String message =
                            statusMessages[ordersViewModel.currentStatus] ??
                                'No orders found.';

                        return Center(
                          child: Text(message),
                        );
                      }

                      return ListView.builder(
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
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
                                            '${order.createdAt.toDate().toLocal().toString().split(' ')[0]}',
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
                                      Text(
                                        '₱ ${order.totalPrice.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[800],
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

  Widget _buildFilterButton(String status, OrderViewModel ordersViewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: TextButton(
        style: TextButton.styleFrom(
          minimumSize: const Size(60, 35),
          backgroundColor: _selectedStatus == status
              ? AppColors.deepMossGreen
              : Colors.grey[200],
          foregroundColor:
              _selectedStatus == status ? Colors.white : Colors.black,
        ),
        onPressed: () {
          setState(() {
            _selectedStatus = status;
            ordersViewModel.filterOrdersByStatus(_selectedStatus);
          });
        },
        child: Text(
          status,
          style: const TextStyle(fontSize: 8.0),
        ),
      ),
    );
  }
}
