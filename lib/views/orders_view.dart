import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/order_viewmodel.dart';
import 'package:unshelf_seller/views/order_details_view.dart';
import 'package:flutter/cupertino.dart';

class OrdersView extends StatefulWidget {
  @override
  _OrdersViewState createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  String? _selectedStatus;

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
          DropdownButton<String>(
            value: _selectedStatus,
            hint: const Text('Filter by Status'),
            items: <String>['All', 'Pending', 'Cancelled', 'Ready', 'Completed']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedStatus = newValue;
                ordersViewModel.filterOrdersByStatus(newValue);
              });
            },
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
                  if (ordersViewModel.currentStatus == 'Pending') {
                    return const Center(
                        child: Text('No pending orders found.'));
                  } else if (ordersViewModel.currentStatus == 'Completed') {
                    return const Center(
                        child: Text('No completed orders found.'));
                  } else if (ordersViewModel.currentStatus == 'Ready') {
                    return const Center(child: Text('No ready orders found.'));
                  } else if (ordersViewModel.currentStatus == 'Cancelled') {
                    return const Center(
                        child: Text('No cancelled orders found.'));
                  } else {
                    return const Center(child: Text('No orders found.'));
                  }
                }

                return ListView.separated(
                  itemCount: ordersViewModel.filteredOrders.length,
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey[300],
                    thickness: 1.0,
                  ),
                  itemBuilder: (context, index) {
                    final order = ordersViewModel.filteredOrders[index];
                    return ListTile(
                      contentPadding: EdgeInsets.all(16.0),
                      title: Row(
                        children: [
                          // Left side: Product Details
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                      color: Colors.grey[300]!,
                                      width:
                                          1.0), // Border to separate from right side
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Product Image
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(
                                          color: Colors.grey, width: 1),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        CupertinoIcons.gift,
                                        size: 30.0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.0),
                                  // Product Name and Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4.0),
                                        Text(
                                          'Order ID: ${order.orderId}',
                                          style: const TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4.0),
                                        Text(
                                          'Created At: ${order.createdAt.toDate().toLocal().toString().split(' ')[0]}',
                                          style: TextStyle(
                                              fontSize: 10.0,
                                              color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Right side: Price and Status
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Price
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 8.0,
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.05,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey[300]!,
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      '₱ ${order.totalPrice.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.03,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      // Status
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.03, // Responsive horizontal padding
                                            vertical: 6.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            border: Border.all(
                                              color: Colors.grey,
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            order.status,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.015,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      // Payment Status (Paid/Not Paid)
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.03,
                                            vertical: 6.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: order.isPaid
                                                ? Colors.green[300]
                                                : Colors.red[300],
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            border: Border.all(
                                              color: Colors.grey,
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            order.isPaid ? 'Paid' : 'Not Paid',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: (MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.015),
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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
}
