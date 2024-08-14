import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/order_viewmodel.dart'; // Update the import path
import 'package:unshelf_seller/models/order_model.dart'; // Update the import path

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/order_viewmodel.dart'; // Update the import path
import 'package:unshelf_seller/models/order_model.dart'; // Update the import path

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
          if (viewModel.isLoading) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Order Details'),
                backgroundColor: Color(0xF6A994E),
              ),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            return Scaffold(
              appBar: AppBar(
                title: Text('Order Details'),
              ),
              body: Center(
                child: Text('Order not found'),
              ),
            );
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Order Details'),
            backgroundColor: Color(0xF6A994E),
          ),
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order ID: ${order.id}', style: TextStyle(fontSize: 20)),
                SizedBox(height: 8),
                Text('Status: ${order.status.toString().split('.').last}',
                    style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('Products:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                if (order.products != null)
                  ...order.products.map((product) {
                    return Text(
                      'Name: ${product.name}, Quantity: ${product.stock}',
                      style: TextStyle(fontSize: 16),
                    );
                  }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}
