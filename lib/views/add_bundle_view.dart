import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:unshelf_seller/viewmodels/bundle_viewmodel.dart';
import 'package:unshelf_seller/components/image_delete.dart';
import 'package:unshelf_seller/models/batch_model.dart';
import 'package:unshelf_seller/utils/colors.dart';
import 'package:unshelf_seller/components/custom_app_bar.dart';
import 'package:unshelf_seller/components/custom_button.dart';

class AddBundleView extends StatefulWidget {
  final Map<String, BatchModel> products;

  AddBundleView({required this.products});

  @override
  State<AddBundleView> createState() => _AddBundleViewState();
}

class _AddBundleViewState extends State<AddBundleView> {
  final Map<String, Map<String, dynamic>> productDetails = {};

  @override
  void initState() {
    super.initState();

    widget.products.forEach((productId, product) {
      productDetails[productId] = {
        'quantity': 1,
        'quantifier': product.quantifier,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: 'Enter Bundle Details',
          onBackPressed: () {
            Provider.of<BundleViewModel>(context, listen: false)
                .clearSelection();
            Navigator.pop(context);
          }),
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
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
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
                          color: AppColors.watermelonRed,
                          fontSize: 10,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter bundle name';
                        }
                        return null;
                      },
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 20.0),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: viewModel.bundleDescriptionController,
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
                          color: Color(0xFFBC4749),
                          fontSize: 10,
                        ),
                      ),
                      maxLines: 3,
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
                      child: Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      value: viewModel.selectedCategory.isEmpty
                          ? null
                          : viewModel.selectedCategory,
                      items: viewModel.categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
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
                      onChanged: (String? newValue) {
                        viewModel.selectedCategory = newValue!;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                    ),
                    const SizedBox(height: 20.0),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
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
                        labelStyle: const TextStyle(color: Colors.black),
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
                        // if (stock > viewModel.maxStock) {
                        //   return 'Max Stock is ${viewModel.maxStock}. Stock cannot be greater than the lowest stock of the products in the bundle';
                        // }
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
                        fillColor: const Color.fromARGB(255, 228, 228, 228),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 12.0),
                        labelStyle: const TextStyle(color: Colors.black),
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
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 20.0),
                    const Text(
                      'Enter the quantity of each product in the bundle',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                    ...widget.products.entries.map((entry) {
                      final productId = entry.key;
                      final product = entry.value;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product Name
                                  Text(
                                    product.product!.name,
                                    style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(
                                      height:
                                          4.0), // Space between name and batch number
                                  // Batch Number
                                  Text(
                                    'Batch: ${product.batchNumber}', // Show the batch number here
                                    style: const TextStyle(
                                        fontSize: 12.0, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Expiry Date
                                  Text(
                                    'Expiry Date:',
                                    style: const TextStyle(
                                        fontSize: 12.0, color: Colors.grey),
                                  ),
                                  Text(
                                    '${product.expiryDate.day.toString().padLeft(2, '0')}/${product.expiryDate.month.toString().padLeft(2, '0')}/${product.expiryDate.year}',
                                    style: const TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      setState(() {
                                        if (productDetails[productId]![
                                                'quantity'] >
                                            1) {
                                          productDetails[productId]![
                                              'quantity'] -= 1;
                                        }
                                      });
                                    },
                                  ),
                                  Text(
                                    productDetails[productId]!['quantity']
                                        .toString(),
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      setState(() {
                                        productDetails[productId]![
                                            'quantity'] += 1;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 15.0),
                    CustomButton(
                      text: 'Create Bundle',
                      onPressed: () async {
                        final form = viewModel.formKey.currentState;

                        if (form != null && form.validate()) {
                          await viewModel.createBundle(productDetails);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bundle created successfully'),
                            ),
                          );
                          viewModel.clearSelection();
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
