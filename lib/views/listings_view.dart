// views/listings_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:unshelf_seller/models/bundle_model.dart';
import 'package:unshelf_seller/models/product_model.dart';
import 'package:unshelf_seller/viewmodels/listing_viewmodel.dart';
import 'package:unshelf_seller/views/product_summary_view.dart';
import 'package:unshelf_seller/views/add_product_view.dart';
import 'package:unshelf_seller/views/add_bundle_view.dart';

class ListingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Consumer<ListingViewModel>(
          builder: (context, viewModel, child) {
            return AppBar(
              title: Text(viewModel.showingProducts
                  ? 'Product Listings'
                  : 'Bundle Listings'),
              actions: [
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
              return Center(child: Text('No products found'));
            } else {
              return Center(child: Text('No bundles found'));
            }
          }

          return ListView.builder(
            itemCount: viewModel.items.length,
            itemBuilder: (context, index) {
              final item = viewModel.items[index];
              final itemId = item.id;
              final itemName = item.name;
              final itemPrice = item.price;

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
                child: ListTile(
                  leading: CachedNetworkImage(
                    imageUrl: item.mainImageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        Icon(Icons.error, size: 50),
                  ),
                  title: Text(itemName),
                  subtitle: Text('₱ ${itemPrice.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          if (item is ProductModel) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddProductView(productId: itemId),
                              ),
                            );
                          } else if (item is BundleModel) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddBundleView(bundleId: itemId),
                              ),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await viewModel.deleteItem(
                              itemId, item is ProductModel);
                        },
                      ),
                    ],
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
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddProductView(),
                  ),
                );
                if (result == true) {
                  Provider.of<ListingViewModel>(context, listen: false)
                      .refreshItems();
                }
              } else {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddBundleView(),
                  ),
                );
                if (result == true) {
                  Provider.of<ListingViewModel>(context, listen: false)
                      .refreshItems();
                }
              }
            },
            child: Icon(Icons.add),
            tooltip: viewModel.showingProducts ? 'Add Product' : 'Add Bundle',
          );
        },
      ),
    );
  }
}
