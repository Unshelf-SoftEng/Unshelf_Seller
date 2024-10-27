import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/product_viewmodel.dart';
import 'package:unshelf_seller/views/image_delete_view.dart';

class UpdateProductView extends StatelessWidget {
  final VoidCallback onProductAdded;
  final String? productId;

  const UpdateProductView(
      {Key? key, required this.onProductAdded, this.productId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductViewModel(productId: productId),
      child: Consumer<ProductViewModel>(builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
              backgroundColor: const Color(0xFF6A994E),
              title: const Text('Add Product Details')),
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
                          child: viewModel.mainImageData != null
                              ? ImageWithDelete(
                                  imageData: viewModel.mainImageData!,
                                  onDelete: viewModel.deleteMainImage,
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
                            // Calculate the width of each item based on the available width
                            double itemWidth =
                                (constraints.maxWidth - 10 * 2.0) / 4 - 10.0;

                            // Retrieve the image list from the view model
                            var imageList = viewModel.additionalImageDataList;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: itemWidth *
                                      ((imageList.length / 4).ceil()),
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      crossAxisSpacing: 2.0,
                                      mainAxisSpacing: 2.0,
                                      childAspectRatio: 1.0,
                                    ),
                                    itemCount: imageList.length,
                                    itemBuilder: (context, index) {
                                      final imageData = imageList[index];
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
                                                    .deleteAdditionalImage(
                                                        index),
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
                                    child: ElevatedButton(
                                      onPressed: () => viewModel.pickImage(
                                          false,
                                          index: imageList.indexOf(null)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF386641),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                      ),
                                      child: const Text(
                                        'Add Image',
                                        style: TextStyle(color: Colors.white),
                                      ),
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
                        style:
                            const TextStyle(fontSize: 12, color: Colors.black),
                      ),
                      const SizedBox(height: 40),
                      Align(
                        alignment: Alignment.center,
                        child: viewModel.isLoading
                            ? const CircularProgressIndicator()
                            : SizedBox(
                                width: 200,
                                height: 30,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (productId == null) {
                                      await viewModel.addProduct(context);
                                    } else {
                                      await viewModel.updateProduct(
                                          context, productId!);
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Product added successfully!'),
                                      ),
                                    );
                                    onProductAdded();
                                    Navigator.pop(context, true);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6A994E),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Update Product'),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
