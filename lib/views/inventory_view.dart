import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/components/custom_app_bar.dart';
import 'package:unshelf_seller/viewmodels/inventory_viewmodel.dart';
import 'package:unshelf_seller/utils/colors.dart';

class InventoryView extends StatefulWidget {
  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  String? selectedProjectId; // Track the selected project
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InventoryViewModel>(context, listen: false).fetchInventory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<InventoryViewModel>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Store Inventory',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Dropdown to select a project
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Select a project'),
                    value: selectedProjectId,
                    items: viewModel.inventoryItems.map((item) {
                      return DropdownMenuItem<String>(
                        value: item.id, // Unique ID of the project/item
                        child: Text(item.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedProjectId = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 12.0),

                // Show batches only for the selected project
                if (selectedProjectId != null)
                  Expanded(
                    child: ListView(
                      children: [
                        // Find the selected project
                        for (var item in viewModel.inventoryItems)
                          if (item.id == selectedProjectId) ...[
                            item.batches.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'No batches available',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  )
                                : Column(
                                    children: item.batches.map<Widget>((batch) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 12.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(
                                              Icons.check_circle_outline,
                                              color: Colors.green,
                                            ),
                                            const SizedBox(width: 8.0),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Batch: ${batch.batchNumber}',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14),
                                                  ),
                                                  const SizedBox(height: 4.0),
                                                  Text(
                                                    'Expiry: ${batch.expiryDate}',
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8.0),
                                            Text(
                                              'Stock: ${batch.stock}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.blueAccent,
                                              ),
                                            ),
                                          ],
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
  }
}
