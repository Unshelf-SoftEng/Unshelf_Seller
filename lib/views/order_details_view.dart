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
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order ID: ${order.orderId}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Buyer: ${order.buyerName}',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                const Text(
                  'Products',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Set the max width for each product card (e.g., 200.0).
                      double maxItemWidth = 200.0;

                      // Calculate the number of columns based on the available width and max item width.
                      int crossAxisCount =
                          (constraints.maxWidth / maxItemWidth).floor();

                      // Ensure at least 2 items per row if the space is small.
                      if (crossAxisCount < 2) {
                        crossAxisCount = 2;
                      }

                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              crossAxisCount, // Dynamically calculated
                          crossAxisSpacing: 12.0, // Space between columns
                          mainAxisSpacing: 12.0, // Space between rows
                          childAspectRatio: 3 /
                              4, // Aspect ratio of each item (width / height)
                        ),
                        itemCount: order.products.length,
                        itemBuilder: (context, index) {
                          final product = order.products[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
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
                                    height: 120, // Fixed height for images
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    // Center widget added here
                                    child: Column(
                                      mainAxisSize: MainAxisSize
                                          .min, // Use minimum space required
                                      children: [
                                        Text(
                                          product.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign
                                              .center, // Center the text
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '${order.items[index].quantity} ${order.products[index].quantifier}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                          ),
                                          textAlign: TextAlign
                                              .center, // Center the text
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Card(
            elevation: 8,
            margin: EdgeInsets.zero, // Make the card stick to the edges
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize
                    .min, // Ensures the card takes up minimal height
                children: [
                  if (order.status == OrderStatus.pending)
                    Container(
                      width: double.infinity,
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
                    )
                  else if (order.status == OrderStatus.ready)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Ready for Pickup',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Pickup Code: ${order.pickUpCode}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    )
                  else if (order.status == OrderStatus.completed)
                    Text(
                      'Completed on: ${DateFormat('yyyy-MM-dd').format(order.completionDate!.toDate())}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
