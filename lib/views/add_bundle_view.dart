import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:unshelf_seller/views/bundle_suggestions_view.dart';
import 'package:unshelf_seller/viewmodels/bundle_viewmodel.dart';
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bundle Image',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => viewModel.pickImage(),
                          child: Container(
                            width: double.infinity,
                            height: 350,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: viewModel.errorFound
                                    ? AppColors.warningColor
                                    : AppColors.lightColor,
                              ),
                              borderRadius: BorderRadius.circular(
                                  8.0), // Optional: rounded corners
                            ),
                            child: viewModel.mainImageData != null
                                ? Stack(
                                    children: [
                                      // Display the image
                                      Center(
                                        child: Image.memory(
                                          viewModel.mainImageData!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_a_photo,
                                            color: Colors.black),
                                        Text(
                                          'Click to Add Main Image',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                        if (viewModel.mainImageData != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.warningColor,
                                  foregroundColor: Colors.white,
                                  alignment: Alignment.center,
                                  minimumSize: const Size(50, 30),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  viewModel.deleteImage();
                                },
                                child: const Text(
                                  'Remove',
                                  style:
                                      TextStyle(fontSize: 12), // Smaller text
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'You can change the main image by clicking on the image',
                                style:
                                    TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                      ],
                    ),
                    if (viewModel.errorFound)
                      const Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text(
                          'Main image is required',
                          style: TextStyle(
                            color: AppColors.warningColor,
                          ),
                        ),
                      ),
                    const SizedBox(height: 15.0),
                    TextFormField(
                      controller: viewModel.bundleNameController,
                      decoration: const InputDecoration(
                        labelText: 'Bundle Name',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.lightColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.lightColor, width: 2.0)),
                        errorBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.warningColor)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a bundle name';
                        }
                        return null;
                      },
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 15.0),
                    TextFormField(
                      controller: viewModel.bundleDescriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.lightColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: AppColors.lightColor, width: 2.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.warningColor),
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
                    const SizedBox(height: 15.0),
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
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.lightColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: AppColors.lightColor, width: 2.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.warningColor),
                        ),
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
                    const SizedBox(height: 15.0),
                    TextFormField(
                      controller: viewModel.bundlePriceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.lightColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: AppColors.lightColor, width: 2.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.warningColor),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter price of the bundle';
                        }
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'Please enter a valid price';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      controller: viewModel.bundleStockController,
                      decoration: const InputDecoration(
                        labelText: 'Stock',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.lightColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.lightColor, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.warningColor),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the bundle stock';
                        }
                        final stock = int.tryParse(value);
                        if (stock == null || stock <= 0) {
                          return 'Please enter a valid stock quantity';
                        }
                        return null;
                      },
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Discount (%)',
                        hintText: 'e.g. 10 for 10%, 0 for no discount',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.lightColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.lightColor, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.warningColor),
                        ),
                      ),
                      controller: viewModel.bundleDiscountController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the discount percentage';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid discount percentage';
                        }
                        if (int.parse(value) < 0 || int.parse(value) > 100) {
                          return 'Please enter a valid discount percentage';
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
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () async {
      //     await Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => BundleSuggestionsView(),
      //       ),
      //     );
      //   },
      //   label: const Text('Want suggestions?',
      //       style: TextStyle(color: Colors.white)),
      //   backgroundColor: AppColors.primaryColor,
      // ),
    );
  }
}
