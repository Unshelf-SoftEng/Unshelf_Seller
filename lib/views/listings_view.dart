import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/models/bundle_model.dart';
import 'package:unshelf_seller/models/product_model.dart';
import 'package:unshelf_seller/viewmodels/listing_viewmodel.dart';
import 'package:unshelf_seller/views/product_details_view.dart';
import 'package:unshelf_seller/views/add_product_view.dart';
import 'package:unshelf_seller/views/select_products_view.dart';
import 'package:unshelf_seller/views/edit_product_view.dart';
import 'package:unshelf_seller/views/edit_bundle_view.dart';
import 'package:unshelf_seller/views/bundle_details_view.dart';
import 'package:unshelf_seller/utils/colors.dart';

class ListingsView extends StatefulWidget {
  @override
  State<ListingsView> createState() => _ListingsViewState();
}

class _ListingsViewState extends State<ListingsView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final searchQuery = _searchController.text;
    Provider.of<ListingViewModel>(context, listen: false)
        .updateSearchQuery(searchQuery);
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
              ),
              style: const TextStyle(color: Colors.white),
              textInputAction: TextInputAction.search,
            )
          : const Text('Listings'),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.cancel : Icons.search),
          onPressed: _toggleSearch,
        ),
        const SizedBox(width: 8),
        Consumer<ListingViewModel>(
          builder: (context, viewModel, _) {
            return DropdownButton<String>(
              value: viewModel.filter,
              dropdownColor: Colors.white,
              underline: const SizedBox(),
              icon:
                  const Icon(Icons.filter_list, color: AppColors.deepMossGreen),
              onChanged: (String? value) {
                if (value != null) {
                  viewModel.setFilter(value);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: 'All',
                  child: Text('All'),
                ),
                DropdownMenuItem(
                  value: 'Bundles',
                  child: Text('Bundles'),
                ),
                DropdownMenuItem(
                  value: 'Products',
                  child: Text('Products'),
                ),
              ],
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<ListingViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.filteredItems.isEmpty) {
          return _buildEmptyState(viewModel.filter == 'Products');
        }

        return ListView.builder(
          itemCount: viewModel.filteredItems.length,
          itemBuilder: (context, index) {
            final item = viewModel.filteredItems[index];
            return _buildItemCard(context, item);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(bool showingProducts) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            showingProducts ? 'No products found' : 'No bundles found',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, dynamic item) {
    final itemId = item.id;
    final itemName = item.name;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4.0,
      child: ListTile(
        contentPadding: const EdgeInsets.all(8.0),
        leading: Image.network(
          item.mainImageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
        title:
            Text(itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: _buildActionButtons(context, item),
        onTap: () {
          if (item is BundleModel) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BundleDetailsView(bundleId: itemId),
              ),
            );
          } else if (item is ProductModel) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailsView(productId: itemId),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, dynamic item) {
    final itemId = item.id;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: AppColors.palmLeaf),
          onPressed: () {
            if (item is ProductModel) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProductView(
                    product: item,
                    onProductAdded: () {
                      Provider.of<ListingViewModel>(context, listen: false)
                          .fetchItems();
                    },
                  ),
                ),
              );
            } else if (item is BundleModel) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditBundleView(bundleId: itemId),
                ),
              );
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: AppColors.watermelonRed),
          onPressed: () async {
            final confirmDelete = await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Confirm Deletion"),
                  content:
                      const Text("Are you sure you want to delete this item?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text("Delete",
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                );
              },
            );
            if (confirmDelete == true) {
              await Provider.of<ListingViewModel>(context, listen: false)
                  .deleteItem(itemId, item is ProductModel);
            }
          },
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Consumer<ListingViewModel>(
      builder: (context, viewModel, _) {
        return FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.add_circle_outline),
                      title: const Text('Add Product'),
                      onTap: () async {
                        Navigator.pop(context); // Close the bottom sheet
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddProductView(
                              onProductAdded: () {
                                Provider.of<ListingViewModel>(context,
                                        listen: false)
                                    .fetchItems();
                              },
                            ),
                          ),
                        );
                        viewModel.fetchItems();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.pages_outlined),
                      title: const Text('Add Bundle'),
                      onTap: () async {
                        Navigator.pop(context);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectProductsView(),
                          ),
                        );
                        viewModel.fetchItems();
                      },
                    ),
                  ],
                );
              },
            );
          },
          tooltip: 'Add Item',
          backgroundColor: AppColors.middleGreenYellow,
          child: const Icon(Icons.add, color: AppColors.deepMossGreen),
        );
      },
    );
  }
}
