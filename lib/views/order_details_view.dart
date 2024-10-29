import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:unshelf_seller/viewmodels/order_viewmodel.dart';

class OrderDetailsView extends StatefulWidget {
  final String orderId;

  const OrderDetailsView({super.key, required this.orderId});

  @override
  _OrderDetailsViewState createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  @override
  void initState() {
    super.initState();
    // Trigger fetching the order details when this widget initializes
    final viewModel = Provider.of<OrderViewModel>(context, listen: false);
    viewModel.selectOrder(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderViewModel>(builder: (context, viewModel, child) {
      final order = viewModel.selectedOrder;

      if (order == null) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Order Details'),
            backgroundColor: const Color(0xFF6A994E),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Center(
            child: viewModel.isLoading
                ? const CircularProgressIndicator()
                : const Text('Order not found'),
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('Order Details'),
          backgroundColor: const Color(0xFF6A994E),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
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
                        style: const TextStyle(
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
              const SizedBox(height: 20),
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
                        childAspectRatio:
                            3 / 4, // Aspect ratio of each item (width / height)
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
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(10)),
                                child: Image.network(
                                  product.product!.mainImageUrl,
                                  width: double.infinity,
                                  height: 120, // Fixed height for images
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        product.product!.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${order.items[index].quantity} ${order.products[index].quantifier}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                        textAlign: TextAlign.center,
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
          margin: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (order.status == 'Pending')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Show confirmation dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm Fulfillment'),
                              content: const Text(
                                  'Are you sure you want to fulfill this order?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    viewModel.fulfillOrder();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Fulfill'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA7C957),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Fulfill Order'),
                    ),
                  )
                else if (order.status == 'Ready')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Order Ready for Pickup',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pickup Code: ${order.pickupCode}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (order.pickupTime != null || order.pickupTime != '')
                        Text(
                          'Pickup Time: ${order.pickupTime}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      const SizedBox(height: 12),
                      if (!order.isPaid)
                        Text(
                          'Amount to be paid at pickup: ₱ ${order.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm Order Completion'),
                                content: const Text(
                                    'Are you sure you want to complete this order?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await viewModel.completeOrder(order.id);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Complete'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          backgroundColor: const Color(0xFFA7C957),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Complete Order'),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      const Text(
                        'Order Completed',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Convert Timestamp to DateTime using toDate() method
                      Text(
                        'Completed at: ${DateFormat.yMMMd().add_jm().format(order.completedAt!.toDate())}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
