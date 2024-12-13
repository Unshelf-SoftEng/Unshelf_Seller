import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/order_viewmodel.dart';
import 'package:unshelf_seller/views/order_details_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:unshelf_seller/utils/colors.dart';

class OrdersView extends StatefulWidget {
  @override
  _OrdersViewState createState() => _OrdersViewState();
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
        ],
      ),
      body: FutureBuilder<void>(
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
                    'Processing': 'No orders currently being processed today.',
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
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Middle Section: Order Info
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order ID: ${order.orderId}',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      '${order.createdAt.toDate().toLocal().toString().split(' ')[0]}',
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
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
                                Text(
                                  '₱ ${order.totalPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800],
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 4.0, horizontal: 12.0),
                                  decoration: BoxDecoration(
                                    color: order.isPaid
                                        ? Colors.green[300]
                                        : Colors.red[300],
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Text(
                                    order.isPaid ? 'Paid' : 'Unpaid',
                                    style: TextStyle(
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
    );
  }

  Widget _buildFilterButton(String status, OrderViewModel ordersViewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.0),
      child: TextButton(
        style: TextButton.styleFrom(
          minimumSize: const Size(60, 30),
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
