import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:unshelf_seller/models/bundle_model.dart';
import 'package:unshelf_seller/models/product_model.dart';
import 'package:unshelf_seller/viewmodels/listing_viewmodel.dart';
import 'package:unshelf_seller/views/product_summary_view.dart';
import 'package:unshelf_seller/views/add_product_view.dart';
import 'package:unshelf_seller/views/select_products_view.dart';
import 'package:unshelf_seller/views/update_product_view.dart';
import 'package:unshelf_seller/views/update_bundle_view.dart';

class ListingsView extends StatefulWidget {
  @override
  _ListingsViewState createState() => _ListingsViewState();
}

class _ListingsViewState extends State<ListingsView> {
  TextEditingController _searchController = TextEditingController();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Consumer<ListingViewModel>(
          builder: (context, viewModel, child) {
            return AppBar(
              title: _isSearching
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(color: Colors.black),
                      onSubmitted: (value) {
                        _onSearchChanged();
                      },
                      textInputAction: TextInputAction.search,
                    )
                  : Text(
                      Provider.of<ListingViewModel>(context).showingProducts
                          ? 'Product Listings'
                          : 'Bundle Listings',
                    ),
              actions: [
                _isSearching
                    ? IconButton(
                        icon: Icon(Icons.cancel),
                        onPressed: () {
                          setState(() {
                            _isSearching = false;
                            _searchController.clear();
                            Provider.of<ListingViewModel>(context,
                                    listen: false)
                                .updateSearchQuery('');
                          });
                        },
                      )
                    : IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          setState(() {
                            _isSearching = true;
                          });
                        },
                      ),
                IconButton(
                  icon: Icon(Icons.swap_horiz),
                  onPressed: () {
                    Provider.of<ListingViewModel>(context, listen: false)
                        .toggleView();
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: Consumer<ListingViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (viewModel.items.isEmpty) {
            if (viewModel.showingProducts) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No products found',
                        style: TextStyle(fontSize: 18, color: Colors.grey)),
                  ],
                ),
              );
            } else {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No bundles found',
                        style: TextStyle(fontSize: 18, color: Colors.grey)),
                  ],
                ),
              );
            }
          }

          return ListView.builder(
            itemCount: viewModel.filteredItems.length,
            itemBuilder: (context, index) {
              final item = viewModel.filteredItems[index];
              final itemId = item.id;
              final itemName = item.name;

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductSummaryView(productId: itemId),
                    ),
                  );
                },
                child: Card(
                  elevation: 4.0,
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(8.0),
                    leading: CachedNetworkImage(
                      imageUrl: item.mainImageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.error, size: 60),
                    ),
                    title: Text(itemName,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.edit, color: Color(0xFF6A994E)),
                          onPressed: () {
                            if (item is ProductModel) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpdateProductView(
                                    productId: itemId,
                                    onProductAdded: () {
                                      // Refresh the product listings
                                      Provider.of<ListingViewModel>(context,
                                              listen: false)
                                          .refreshItems();
                                    },
                                  ),
                                ),
                              );
                            } else if (item is BundleModel) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpdateBundleView(
                                    bundleId: itemId,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await viewModel.deleteItem(
                                itemId, item is ProductModel);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Consumer<ListingViewModel>(
        builder: (context, viewModel, child) {
          return FloatingActionButton(
            onPressed: () async {
              if (viewModel.showingProducts) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddProductView(
                      onProductAdded: () {
                        Provider.of<ListingViewModel>(context, listen: false)
                            .fetchItems();
                      },
                    ),
                  ),
                );
              } else {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectProductsView(),
                  ),
                );
              }
            },
            tooltip: viewModel.showingProducts ? 'Add Product' : 'Add Bundle',
            backgroundColor: Colors.green,
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}
