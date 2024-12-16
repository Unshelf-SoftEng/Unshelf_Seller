import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:unshelf_seller/components/custom_button.dart';
import 'package:unshelf_seller/viewmodels/bundle_viewmodel.dart';
import 'package:unshelf_seller/utils/colors.dart';
import 'package:unshelf_seller/components/custom_app_bar.dart';
import 'package:unshelf_seller/components/image_delete.dart';

class EditBundleView extends StatefulWidget {
  final String bundleId;

  EditBundleView({required this.bundleId});

  @override
  State<EditBundleView> createState() => _EditBundleViewState();
}

class _EditBundleViewState extends State<EditBundleView> {
  final Map<String, Map<String, dynamic>> productDetails = {};
  late BundleViewModel viewModel;

  @override
  void initState() {
    super.initState();

    viewModel = Provider.of<BundleViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await viewModel.initializeBundle(widget.bundleId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: 'Edit Bundle Details',
          onBackPressed: () {
            Provider.of<BundleViewModel>(context, listen: false)
                .clearSelection();
            Navigator.pop(context);
          }),
      body: Consumer<BundleViewModel>(
        builder: (context, viewModel, child) {
          return viewModel.isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: viewModel.formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Image Section
                          GestureDetector(
                            onTap: () => viewModel.pickImage(),
                            child: Container(
                              width: double.infinity,
                              height: 300,
                              color: const Color(0xFF386641),
                              child: viewModel.mainImageData != null
                                  ? ImageWithDelete(
                                      imageData: viewModel.mainImageData!,
                                      onDelete: viewModel.deleteImage,
                                      width: 400.0,
                                      height: 400.0,
                                      margin: EdgeInsets.all(0),
                                    )
                                  : const Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_a_photo,
                                              color: Colors.white),
                                          Text('Add Main Image',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          // Bundle Name Field
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Name',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 5),
                          TextFormField(
                            controller: viewModel.bundleNameController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  const Color.fromARGB(255, 228, 228, 228),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10.0),
                              labelStyle: const TextStyle(color: Colors.black),
                              errorStyle: const TextStyle(
                                  color: AppColors.watermelonRed, fontSize: 10),
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
                          // Bundle Description Field
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Description',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 5),
                          TextFormField(
                            controller: viewModel.bundleDescriptionController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  const Color.fromARGB(255, 228, 228, 228),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10.0),
                              labelStyle: const TextStyle(color: Colors.black),
                              errorStyle: const TextStyle(
                                  color: Color(0xFFBC4749), fontSize: 10),
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
                          // Category Dropdown Field
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Category',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
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
                              fillColor:
                                  const Color.fromARGB(255, 228, 228, 228),
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
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black),
                          ),
                          const SizedBox(height: 20.0),
                          // Price Field
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Price',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 5),
                          TextFormField(
                            controller: viewModel.bundlePriceController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  const Color.fromARGB(255, 228, 228, 228),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 12.0),
                              labelStyle: const TextStyle(color: Colors.black),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d*$'))
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
                          // Quantity Field
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Quantity',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 5),
                          TextFormField(
                            controller: viewModel.bundleStockController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  const Color.fromARGB(255, 228, 228, 228),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 12.0),
                              labelStyle: const TextStyle(color: Colors.black),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the bundle stock';
                              }
                              final stock = int.tryParse(value);
                              if (stock == null || stock <= 0) {
                                return 'Please enter a valid stock number';
                              }
                              return null;
                            },
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 20.0),
                          // Discount Field
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Discount (%)',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 5),
                          TextFormField(
                            controller: viewModel.bundleDiscountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  const Color.fromARGB(255, 228, 228, 228),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 12.0),
                              labelStyle: const TextStyle(color: Colors.black),
                            ),
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 40.0),

                          CustomButton(
                            text: 'Update Bundle',
                            onPressed: () async {
                              if (viewModel.formKey.currentState?.validate() ??
                                  false) {
                                await viewModel.updateBundle();
                                viewModel.clearSelection();
                                Navigator.pop(context);
                              }
                            },
                          ),
                          const SizedBox(height: 20.0),
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
