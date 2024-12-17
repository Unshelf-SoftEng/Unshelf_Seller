import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/batch_history_viewmodel.dart';
import 'package:unshelf_seller/components/custom_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:unshelf_seller/utils/colors.dart';

class BatchHistoryView extends StatefulWidget {
  final String batchId;

  const BatchHistoryView({super.key, required this.batchId});

  @override
  State<BatchHistoryView> createState() => _BatchHistoryViewState();
}

class _BatchHistoryViewState extends State<BatchHistoryView> {
  late BatchHistoryViewModel viewModel;

  @override
  void initState() {
    super.initState();

    // Initialize the viewModel here
    viewModel = Provider.of<BatchHistoryViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchBatchHistory(widget.batchId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen to updates from the viewModel
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Batch History',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Consumer<BatchHistoryViewModel>(
        builder: (context, viewModel, child) {
          final batchKeys = viewModel.batchHistory.keys.toList();

          // Filter to only include the batchId
          final filteredKeys =
              batchKeys.where((key) => key == widget.batchId).toList();

          if (filteredKeys.isEmpty) {
            return const Center(
              child: Text('No history available for this batch.'),
            );
          }

          final batchKey = filteredKeys[0];
          final batchData = viewModel.batchHistory[batchKey];
          final orderHistory = batchData?['orderHistory'] as List;

          return ListView(
            padding: const EdgeInsets.all(8),
            children: [
              // Batch summary information
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text('Batch: $batchKey'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Total Products Sold: ${batchData?['totalProductsSold']}'),
                      Text(
                        'Total Sale: \u20B1 ${batchData?['totalSaleSize'].toStringAsFixed(2)}',
                        style: const TextStyle(fontFamily: 'Roboto'),
                      ),
                    ],
                  ),
                ),
              ),
              // Order history list
              ...orderHistory.map<Widget>((order) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: order['soldWithBundle']
                        ? const Icon(CupertinoIcons.gift,
                            color: AppColors.primaryColor)
                        : const ImageIcon(
                            AssetImage("assets/icons/add_product.png")),
                    title: Text('Order ID: ${order['orderId']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sold Quantity: ${order['soldQuantity']}'),
                        Text(
                          'Price: \u20B1 ${order['soldPrice'].toStringAsFixed(2)}',
                          style: const TextStyle(fontFamily: 'Roboto'),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
