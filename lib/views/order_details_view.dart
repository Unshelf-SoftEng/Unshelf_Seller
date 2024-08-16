import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:unshelf_seller/models/order_model.dart';
import 'package:unshelf_seller/viewmodels/order_viewmodel.dart';

class OrderDetailsView extends StatelessWidget {
  final String orderId;

  OrderDetailsView({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderViewModel>(
      builder: (context, viewModel, child) {
        // Trigger fetching the order details when this widget builds
        viewModel.selectOrder(orderId);

        final order = viewModel.selectedOrder;

        if (order == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Order Details'),
              backgroundColor: Color(0xFF6A994E),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: Center(
              child: viewModel.isLoading
                  ? CircularProgressIndicator()
                  : Text('Order not found'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Order Details'),
            backgroundColor: Color(0xFF6A994E),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  margin: EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order ID: ${order.id}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Buyer: ${order.buyerName}',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 10),
                        Divider(),
                        Text(
                          'Products',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Number of columns
                      crossAxisSpacing: 12.0, // Horizontal space between items
                      mainAxisSpacing: 12.0, // Vertical space between items
                      childAspectRatio:
                          3 / 4, // Aspect ratio of each item (width / height)
                    ),
                    itemCount: order.products.length,
                    itemBuilder: (context, index) {
                      final product = order.products[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10)),
                              child: Image.network(
                                product.mainImageUrl,
                                width: double.infinity,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Qty: ${order.items[index].quantity}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
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
                ),
                SizedBox(height: 20),
                Card(
                  margin: EdgeInsets.symmetric(vertical: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (order.status == OrderStatus.pending)
                          Center(
                            child: Container(
                              width: double
                                  .infinity, // Ensures the container takes up the full width
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0), // Optional padding
                              child: ElevatedButton(
                                onPressed: () {
                                  // Show confirmation dialog
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Confirm Fulfillment'),
                                        content: Text(
                                            'Are you sure you want to fulfill this order?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Close the dialog
                                            },
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              viewModel
                                                  .fulfillOrder(); // Fulfill the order
                                              Navigator.of(context)
                                                  .pop(); // Close the dialog
                                            },
                                            child: Text('Fulfill'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFA7C957),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text('Fulfill Order'),
                              ),
                            ),
                          )
                        else if (order.status == OrderStatus.ready)
                          Center(
                            child: Container(
                              width: double
                                  .infinity, // Ensures the container takes up the full width
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0), // Optional padding
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment
                                    .center, // Aligns content in the center
                                children: [
                                  Text(
                                    'Ready for Pickup',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Pickup Code: ${order.pickUpCode}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (order.status == OrderStatus.completed)
                          Center(
                            child: Container(
                              width: double
                                  .infinity, // Ensures the container takes up the full width
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0), // Optional padding
                              child: Text(
                                'Completed on: ${DateFormat('yyyy-MM-dd').format(order.completionDate!.toDate())}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign
                                    .center, // Center the text inside the container
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
