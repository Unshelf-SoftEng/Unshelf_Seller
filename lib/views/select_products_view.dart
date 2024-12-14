import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/select_products_viewmodel.dart';
import 'package:unshelf_seller/views/add_bundle_view.dart';
import 'package:unshelf_seller/utils/colors.dart';
import 'package:intl/intl.dart';

class SelectProductsView extends StatefulWidget {
  const SelectProductsView({super.key});

  @override
  State<SelectProductsView> createState() => _SelectProductsViewState();
}

class _SelectProductsViewState extends State<SelectProductsView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SelectProductsViewModel>(context, listen: false)
          .fetchProducts();
    });
  }

  void _onSearchChanged() {
    final searchQuery = _searchController.text;
    Provider.of<SelectProductsViewModel>(context, listen: false)
        .updateSearchQuery(searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SelectProductsViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Choose Products for Bundle',
          style: TextStyle(
              color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.palmLeaf,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.deepMossGreen,
          ),
          onPressed: () {
            viewModel.clearSelection();
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
      body: Column(
        children: [
          // Search bar moved to the body
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search products...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _onSearchChanged();
              },
            ),
          ),
          // Product List
          Expanded(
            child: Consumer<SelectProductsViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (viewModel.items.isEmpty) {
                  return const Center(
                    child: Text('No products available'),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: viewModel.filteredItems.length,
                    itemBuilder: (context, index) {
                      final product = viewModel.filteredItems[index];
                      return _ProductListTile(
                        productId: product.batchNumber,
                        name: product.product!.name,
                        mainImageUrl: product.product!.mainImageUrl,
                        price: product.price,
                        expiryDate: product.expiryDate,
                        isSelected: viewModel.selectedItems.keys
                            .contains(product.batchNumber),
                        onTap: () =>
                            viewModel.addProductToBundle(product.batchNumber),
                        onLongPress: () => viewModel
                            .removeProductFromBundle(product.batchNumber),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (viewModel.selectedItems.length < 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select at least two products'),
              ),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddBundleView(products: viewModel.selectedItems),
            ),
          ).then((result) {
            if (result == true) {
              viewModel.clearSelection();
              Navigator.pop(context, true);
            }
          });
        },
        backgroundColor: AppColors.middleGreenYellow,
        child: const Icon(Icons.arrow_forward, color: Colors.black),
      ),
    );
  }
}

class _ProductListTile extends StatelessWidget {
  final String mainImageUrl;
  final String productId;
  final String name;
  final double price;
  final DateTime expiryDate;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  _ProductListTile({
    required this.mainImageUrl,
    required this.productId,
    required this.name,
    required this.price,
    required this.expiryDate,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
          vertical: 4.0, horizontal: 8.0), // Add margin to each tile
      elevation: 2.0,
      child: ListTile(
        contentPadding: const EdgeInsets.all(8.0),
        leading: Image.network(
          mainImageUrl,
          width: 50.0,
          height: 50.0,
          fit: BoxFit.cover,
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.green : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Expiry Date: ${DateFormat('MM-dd-yyyy').format(expiryDate)}"),
          ],
        ),
        tileColor: isSelected
            ? AppColors.palmLeaf.withOpacity(0.1)
            : Colors.transparent,
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
