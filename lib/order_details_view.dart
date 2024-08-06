// views/order_details_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/order_viewmodel.dart';

class OrderDetailsView extends StatelessWidget {
  final String orderId;

  OrderDetailsView({required this.orderId});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<OrderViewModel>(context);
    viewModel.selectOrder(orderId);

    final order = viewModel.selectedOrder;

    if (order == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Order Details'),
        ),
        body: Center(
          child: Text('Order not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${order.id}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            Text('Item: ${order.item}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Quantity: ${order.quantity}', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
