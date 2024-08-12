// views/add_bundle_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/bundle_viewmodel.dart';

class AddBundleView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product Bundle'),
      ),
      body: Consumer<BundleViewModel>(
        builder: (context, viewModel, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Bundle Name'),
                  onChanged: (value) => viewModel.setNewBundleName(value),
                ),
                SizedBox(height: 16.0),
                Expanded(
                  child: ListView(
                    children: [
                      // Example product list (replace with actual product data)
                      _ProductListTile(
                        productId: '1',
                        name: 'Product A',
                        isSelected: viewModel.selectedProductIds.contains('1'),
                        onTap: () => viewModel.addProductToBundle('1'),
                        onLongPress: () =>
                            viewModel.removeProductFromBundle('1'),
                      ),
                      _ProductListTile(
                        productId: '2',
                        name: 'Product B',
                        isSelected: viewModel.selectedProductIds.contains('2'),
                        onTap: () => viewModel.addProductToBundle('2'),
                        onLongPress: () =>
                            viewModel.removeProductFromBundle('2'),
                      ),
                      // Add more products here
                    ],
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: viewModel.createBundle,
                  child: Text('Create Bundle'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProductListTile extends StatelessWidget {
  final String productId;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ProductListTile({
    required this.productId,
    required this.name,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      tileColor: isSelected ? Colors.green[100] : Colors.white,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
