import 'package:flutter/material.dart';

class OrderHistoryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Analytics'),
        backgroundColor: const Color(0xFF6A994E),
        foregroundColor: const Color(0xFFFFFFFF),
        titleTextStyle: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 20,
            fontWeight: FontWeight.bold),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF386641),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: const Color(0xFFC8DD96),
            height: 4.0,
          ),
        ),
      ),
      body: FutureBuilder(
        // Replace with the actual data fetching code
        future: fetchOrderHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading orders'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found'));
          }

          final orders = snapshot.data!;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return ListTile(
                title: Text('Order #${order.id}'),
                subtitle: Text('Total: ₱${order.totalAmount}'),
                trailing: Text(order.status),
                onTap: () {
                  // Handle order tap (e.g., navigate to order details)
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Order>> fetchOrderHistory() async {
    // Simulate a network request
    await Future.delayed(const Duration(seconds: 2));
    return [
      Order(id: 1, totalAmount: 100.0, status: 'Completed'),
      Order(id: 2, totalAmount: 50.0, status: 'Pending'),
    ];
  }
}

class Order {
  final int id;
  final double totalAmount;
  final String status;

  Order({required this.id, required this.totalAmount, required this.status});
}
