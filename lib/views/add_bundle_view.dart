import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:unshelf_seller/viewmodels/bundle_viewmodel.dart';
import 'package:unshelf_seller/views/image_delete_view.dart';
import 'package:unshelf_seller/views/bundle_suggestions_view.dart';
import 'package:unshelf_seller/models/bundle_model.dart';

class AddBundleView extends StatelessWidget {
  final String? bundleId;
  final BundleModel? bundle;

  AddBundleView({this.bundleId, this.bundle});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<BundleViewModel>(context, listen: false);

    if (bundle != null) {
      viewModel.initializeControllers(bundle!);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product Bundle'),
        actions: [
          IconButton(
            icon: Icon(Icons.autorenew), // Icon for AI suggestions
            onPressed: () async {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => BundleSuggestionsView(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<BundleViewModel>(
        builder: (context, viewModel, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: viewModel.formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => viewModel.pickImage(),
                      child: Container(
                        width: double.infinity,
                        height: 300,
                        color: const Color(0xFF386641),
                        child: viewModel.mainImageData != null
                            ? ImageWithDelete(
                                imageData: viewModel.mainImageData!,
                                onDelete: viewModel.deleteMainImage,
                                width: 400.0,
                                height: 400.0, // Add border
                                margin: EdgeInsets.all(0),
                              )
                            : const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo,
                                        color: Colors.white),
                                    Text(
                                      'Add Main Image',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    const Text(
                      'Select Products to Add to Bundle',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListView.builder(
                          itemCount: viewModel.products.length,
                          itemBuilder: (context, index) {
                            final product = viewModel.products[index];
                            return _ProductListTile(
                              mainImageUrl: product.mainImageUrl,
                              productId: product.id,
                              name: product.name,
                              stock: product.stock,
                              isSelected: viewModel.selectedProductIds
                                  .contains(product.id),
                              onTap: () =>
                                  viewModel.addProductToBundle(product.id),
                              onLongPress: () =>
                                  viewModel.removeProductFromBundle(product.id),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Name',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: viewModel.bundleNameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromARGB(255, 228, 228, 228),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                        labelStyle: const TextStyle(color: Colors.black),
                        errorStyle: const TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a bundle name';
                        }
                        return null;
                      },
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 20.0),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Price',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: viewModel.bundlePriceController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromARGB(255, 228, 228, 228),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 12.0),
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*$')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        try {
                          double.parse(value);
                        } catch (e) {
                          return 'Invalid price format';
                        }
                        return null;
                      },
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 20.0),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: viewModel.bundleStockController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromARGB(255, 228, 228, 228),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 12.0),
                        labelStyle: const TextStyle(color: Colors.black),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the bundle stock';
                        }
                        final stock = int.tryParse(value);
                        if (stock == null || stock <= 0) {
                          return 'Please enter a valid stock number';
                        }
                        if (stock > viewModel.maxStock) {
                          return 'Max Stock is ${viewModel.maxStock}. Stock cannot be greater than the lowest stock of the products in the bundle';
                        }
                        return null;
                      },
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 20.0),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Discount (%)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: viewModel.bundleDiscountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color.fromARGB(255, 228, 228, 228),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 12.0),
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      validator: (value) {
                        final intValue = int.tryParse(value ?? '');
                        if (intValue == null ||
                            intValue < 0 ||
                            intValue > 100) {
                          return 'Please enter a valid percentage between 0 and 100';
                        }
                        return null;
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly, // Allows only digits
                      ],
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 40.0),
                    ElevatedButton(
                      onPressed: () {
                        final form = viewModel.formKey.currentState;

                        if (form != null && form.validate()) {
                          viewModel.createBundle();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bundle created successfully'),
                            ),
                          );
                          Navigator.pop(context, true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Please fill in all required fields'),
                            ),
                          );
                        }
                      },
                      child: Text('Create Bundle'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductListTile extends StatelessWidget {
  final String mainImageUrl;
  final String productId;
  final String name;
  final int stock;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  _ProductListTile({
    required this.mainImageUrl,
    required this.productId,
    required this.name,
    required this.stock,
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
        subtitle: Text('Stock: $stock'),
        tileColor:
            isSelected ? Colors.green.withOpacity(0.1) : Colors.transparent,
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
