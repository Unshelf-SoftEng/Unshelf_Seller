import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/order_viewmodel.dart';
import 'package:unshelf_seller/models/order_model.dart';

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
      body: Column(
        children: [
          // Filter buttons
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _FilterButton(
                status: OrderStatus.all,
                label: 'All',
              ),
              _FilterButton(
                status: OrderStatus.pending,
                label: 'Pending',
              ),
              _FilterButton(
                status: OrderStatus.completed,
                label: 'Completed',
              ),
              _FilterButton(
                status: OrderStatus.shipped,
                label: 'Shipped',
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: Consumer<OrderViewModel>(
              builder: (context, viewModel, child) {
                final orders = viewModel.filteredOrders;
                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return ListTile(
                      title: Text('Order ID: ${order.id}'),
                      subtitle: Text(
                          'Item: ${order.item}\nQuantity: ${order.quantity}'),
                      contentPadding: EdgeInsets.all(16.0),
                      tileColor:
                          index % 2 == 0 ? Colors.grey[200] : Colors.white,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final OrderStatus status;
  final String label;

  const _FilterButton({
    required this.status,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<OrderViewModel>(context);
    final isSelected = viewModel.currentStatus == status;

    return ElevatedButton(
      onPressed: isSelected ? null : () => viewModel.setFilter(status),
      child: Text(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: isSelected ? Colors.white : Colors.black,
        backgroundColor: isSelected
            ? Color(0xFFA7C957)
            : Colors.white, // White text for selected button
      ),
    );
  }
}
