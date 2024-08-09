// views/orders_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/order_viewmodel.dart';

class OrdersView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Fetch orders when the view is built
    final ordersViewModel = Provider.of<OrderViewModel>(context, listen: false);
    ordersViewModel.fetchOrders();

    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: Consumer<OrderViewModel>(
        builder: (context, viewModel, child) {
          final orders = viewModel.orders;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return ListTile(
                title: Text('Order ID: ${order.id}'),
                subtitle:
                    Text('Item: ${order.item}\nQuantity: ${order.quantity}'),
                contentPadding: EdgeInsets.all(16.0),
                tileColor: index % 2 == 0 ? Colors.grey[200] : Colors.white,
              );
            },
          );
        },
      ),
    );
  }
}
