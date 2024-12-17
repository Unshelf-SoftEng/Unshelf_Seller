import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/components/custom_app_bar.dart';
import 'package:unshelf_seller/viewmodels/inventory_viewmodel.dart';
import 'package:unshelf_seller/utils/colors.dart';
import 'package:unshelf_seller/views/batch_history_view.dart';
import 'package:intl/intl.dart';

class InventoryView extends StatefulWidget {
  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> filteredItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<InventoryViewModel>(context, listen: false);
      viewModel.fetchInventory();
      filteredItems = viewModel.inventoryItems;
    });

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final viewModel = Provider.of<InventoryViewModel>(context, listen: false);
    setState(() {
      filteredItems = viewModel.inventoryItems
          .where((item) => item.name
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<InventoryViewModel>(context);

    return Scaffold(
      appBar: CustomAppBar(
          title: 'Store Inventory',
          onBackPressed: () {
            viewModel.clearData();
            Navigator.pop(context);
          }),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          // Loading or Inventory List
          Expanded(
            child: viewModel.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 8.0),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ExpansionTile(
                          leading: const Icon(Icons.inventory_2,
                              color: AppColors.primaryColor),
                          title: Text(
                            item.name,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          children: [
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Batch Details:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  const SizedBox(height: 6.0),
                                  if (item.batches.isEmpty) ...[
                                    const Text(
                                      'No batches available',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ] else ...[
                                    Column(
                                      children:
                                          item.batches.map<Widget>((batch) {
                                        return GestureDetector(
                                          onTap: () async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      BatchHistoryView(
                                                          batchId: batch
                                                              .batchNumber)),
                                            );
                                          },
                                          child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 0.0),
                                            leading: const Icon(
                                              Icons.check_circle_outline,
                                              color: AppColors.lightColor,
                                            ),
                                            title: Text(
                                              'Batch: ${batch.batchNumber}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            subtitle: Text(
                                              'Stock: ${batch.stock} | Expiry: ${DateFormat('MMMM d, y h:mm a').format(batch.expiryDate)}',
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
