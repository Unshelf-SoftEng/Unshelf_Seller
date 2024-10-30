import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/select_products_viewmodel.dart';
import 'package:unshelf_seller/views/add_bundle_view.dart';

class SelectProductsView extends StatefulWidget {
  @override
  _SelectProductsViewState createState() => _SelectProductsViewState();
}

class _SelectProductsViewState extends State<SelectProductsView> {
  @override
  void initState() {
    super.initState();
    // Fetch products when the view initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SelectProductsViewModel>(context, listen: false)
          .fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SelectProductsViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Products To Add to Bundle'),
        backgroundColor: const Color(0xFF6A994D),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddBundleView(
                    fromSuggestions: false,
                    selectedProductIds: viewModel.selectedProductIds.toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: viewModel.products.length,
          itemBuilder: (context, index) {
            final product = viewModel.products[index];
            return _ProductListTile(
              productId: product.batchNumber,
              name: product.product!.name,
              mainImageUrl: product.product!.mainImageUrl,
              price: product.price,
              isSelected:
                  viewModel.selectedProductIds.contains(product.batchNumber),
              onTap: () => viewModel.addProductToBundle(product.batchNumber),
              onLongPress: () =>
                  viewModel.removeProductFromBundle(product.batchNumber),
            );
          },
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
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  _ProductListTile({
    required this.mainImageUrl,
    required this.productId,
    required this.name,
    required this.price,
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
        subtitle: Text('Price: $price'),
        tileColor:
            isSelected ? Colors.green.withOpacity(0.1) : Colors.transparent,
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
