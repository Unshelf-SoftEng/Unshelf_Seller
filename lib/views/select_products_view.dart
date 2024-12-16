import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/components/custom_app_bar.dart';
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
          .fetchAllBatches();
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
      appBar: CustomAppBar(
        title: 'Select Products for Bundle',
        onBackPressed: () {
          viewModel.clearSelection();
          Navigator.pop(context);
        },
      ),
      body: viewModel.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.60,
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: false,
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          contentPadding: const EdgeInsets.only(top: 8),
                        ),
                        style: const TextStyle(fontSize: 14),
                        onChanged: (query) {
                          _onSearchChanged();
                        },
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButton<String>(
                          hint: const Text('Sort By'),
                          value: viewModel.sortBy,
                          items: [
                            DropdownMenuItem<String>(
                              value: 'name',
                              child: Text('Name'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'expiryDate',
                              child: Text('Expiry Date'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              viewModel.sortItems(value);
                            }
                          },
                        ),
                      ),
                    ),
                  ]),
                ),
                Text('If you want to unselect a product, long press on it.'),
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
                            final batch = viewModel.filteredItems[index];
                            return _ProductListTile(
                              productId: batch.batchNumber,
                              name: batch.product!.name,
                              mainImageUrl: batch.product!.mainImageUrl,
                              price: batch.price,
                              expiryDate: batch.expiryDate,
                              isSelected: viewModel.selectedItems.keys
                                  .contains(batch.batchNumber),
                              onTap: () => viewModel
                                  .addProductToBundle(batch.batchNumber),
                              onLongPress: () => viewModel
                                  .removeProductFromBundle(batch.batchNumber),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
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
        backgroundColor: AppColors.primaryColor,
        label: const Text(
          'Next',
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        ),
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
