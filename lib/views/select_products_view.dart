import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/select_products_viewmodel.dart';
import 'package:unshelf_seller/views/add_bundle_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SelectProductsView extends StatefulWidget {
  @override
  _SelectProductsViewState createState() => _SelectProductsViewState();
}

class _SelectProductsViewState extends State<SelectProductsView> {
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Fetch products when the view initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SelectProductsViewModel>(context, listen: false)
          .fetchProducts();
    });
  }

  void _onSearchChanged() {
    final searchQuery = _searchController.text;
    print(searchQuery);
    Provider.of<SelectProductsViewModel>(context, listen: false)
        .updateSearchQuery(searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SelectProductsViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.black),
                onChanged: (value) {
                  _onSearchChanged();
                },
                textInputAction: TextInputAction.search,
              )
            : Text('Select Products'),
        backgroundColor: const Color(0xFF6A994D),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          _isSearching
              ? IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                      Provider.of<SelectProductsViewModel>(context,
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
        ],
      ),
      body: Consumer<SelectProductsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            // Show a loading indicator while fetching products
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (viewModel.products.isEmpty) {
            // Handle case where no products are available
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
                  isSelected: viewModel.selectedProducts.keys
                      .contains(product.batchNumber),
                  onTap: () =>
                      viewModel.addProductToBundle(product.batchNumber),
                  onLongPress: () =>
                      viewModel.removeProductFromBundle(product.batchNumber),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddBundleView(products: viewModel.selectedProducts),
            ),
          );
        },
        backgroundColor: const Color(0xFF6A994D),
        child: const Icon(Icons.arrow_forward),
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
        tileColor:
            isSelected ? Colors.green.withOpacity(0.1) : Colors.transparent,
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
