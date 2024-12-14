import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/product_viewmodel.dart';
import 'package:unshelf_seller/components/image_delete.dart';
import 'package:unshelf_seller/models/product_model.dart';
import 'package:unshelf_seller/components/custom_button.dart';
import 'package:unshelf_seller/components/custom_app_bar.dart';

class EditProductView extends StatefulWidget {
  final VoidCallback onProductAdded;
  final ProductModel product;

  const EditProductView({
    Key? key,
    required this.onProductAdded,
    required this.product,
  }) : super(key: key);

  @override
  State<EditProductView> createState() => _EditProductViewState();
}

class _EditProductViewState extends State<EditProductView> {
  late ProductViewModel viewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel = context.read<ProductViewModel>();
      viewModel.loadProduct(
          widget.product); // Load product once after the build phase
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductViewModel>(builder: (context, viewModel, child) {
      return Scaffold(
        appBar: CustomAppBar(
            title: 'Edit Product Details',
            onBackPressed: () {
              Navigator.pop(context);
              viewModel.clearData();
            }),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green, width: 5),
                        color: Colors.transparent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16.0),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Product Details',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    Text(
                      'Enter product details below',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                )
              ]),
              const SizedBox(height: 30.0),
              Form(
                key: viewModel.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => viewModel.pickImage(true),
                      child: Container(
                        width: double.infinity,
                        height: 350,
                        color: const Color(0xFF386641),
                        child: viewModel.mainImageState.data != null
                            ? ImageWithDelete(
                                imageData: viewModel.mainImageState.data!,
                                onDelete: () =>
                                    viewModel.deleteImage(true, null),
                                width: 400.0,
                                height: 400.0,
                                margin: const EdgeInsets.all(0),
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
                    const SizedBox(height: 20),
                    const Text(
                      'Product Gallery',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double itemWidth =
                              (constraints.maxWidth - 10 * 2.0) / 4 - 10.0;

                          var imageList = viewModel.additionalImages;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height:
                                    itemWidth * ((imageList.length / 4).ceil()),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 2.0,
                                    mainAxisSpacing: 2.0,
                                    childAspectRatio: 1.0,
                                  ),
                                  itemCount: imageList.length,
                                  itemBuilder: (context, index) {
                                    final imageData = imageList[index].data;
                                    return Container(
                                      width: itemWidth,
                                      height: itemWidth,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: imageData != null
                                              ? Colors.white
                                              : Colors.transparent,
                                          width: 1.0,
                                        ),
                                        color: imageData == null
                                            ? Colors.grey[200]
                                            : null, // Placeholder color for no image
                                      ),
                                      child: imageData != null
                                          ? ImageWithDelete(
                                              imageData: imageData,
                                              width: itemWidth,
                                              height: itemWidth,
                                              onDelete: () => viewModel
                                                  .deleteImage(false, index),
                                            )
                                          : Center(
                                              child: Icon(
                                                Icons.add_a_photo,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              if (imageList.length >= 4)
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    child: Text(
                                      'Max images have been added',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Center(
                                  child: CustomButton(
                                    text: 'Add Addtional Image',
                                    onPressed: () => viewModel.pickImage(false),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                    if (viewModel.errorFound)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Main image is required',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 20),
                    const Text(
                      'Name',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      controller: viewModel.nameController,
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
                          return 'Please enter a product name';
                        }
                        return null;
                      },
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: viewModel.descriptionController,
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
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
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
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.center,
                      child: viewModel.isLoading
                          ? const CircularProgressIndicator()
                          : CustomButton(
                              text: 'Update Product',
                              onPressed: () async {
                                await viewModel.updateProduct(context);

                                if (await viewModel.updateProduct(context)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Product edited successfully!'),
                                    ),
                                  );
                                  viewModel.clearData();
                                  widget.onProductAdded();
                                  Navigator.pop(context, true);
                                }
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
