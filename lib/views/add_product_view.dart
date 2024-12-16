import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/product_viewmodel.dart';
import 'package:unshelf_seller/utils/colors.dart';
import 'package:unshelf_seller/components/custom_app_bar.dart';
import 'package:unshelf_seller/components/custom_button.dart';
import 'package:unshelf_seller/views/product_details_view.dart';

class AddProductView extends StatelessWidget {
  final VoidCallback onProductAdded;

  const AddProductView({super.key, required this.onProductAdded});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductViewModel(),
      child: Consumer<ProductViewModel>(builder: (context, viewModel, child) {
        return Scaffold(
          appBar: CustomAppBar(
              title: 'Enter Product Details',
              onBackPressed: () {
                viewModel.clearData();
                Navigator.pop(context);
              }),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Form(
                  key: viewModel.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Product Image',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => viewModel.pickImage(true),
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
                              child: viewModel.mainImageState.data != null
                                  ? Stack(
                                      children: [
                                        // Display the image
                                        Center(
                                          child: Image.memory(
                                            viewModel.mainImageState.data!,
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
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                          if (viewModel.mainImageState.data != null)
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
                                    viewModel.deleteImage(true, null);
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
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                ),
                              ],
                            ),
                        ],
                      ),
                      // SizedBox(
                      //   width: double.infinity,
                      //   child: LayoutBuilder(
                      //     builder: (context, constraints) {
                      //       // Calculate the width of each item based on the available width
                      //       double itemWidth =
                      //           (constraints.maxWidth - 10 * 2.0) / 4 - 10.0;

                      //       // Retrieve the image list from the view model
                      //       var imageList = viewModel.additionalImages;

                      //       return Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           SizedBox(
                      //             height: itemWidth *
                      //                 ((imageList.length / 4).ceil()),
                      //             child: GridView.builder(
                      //               shrinkWrap: true,
                      //               physics:
                      //                   const NeverScrollableScrollPhysics(),
                      //               gridDelegate:
                      //                   const SliverGridDelegateWithFixedCrossAxisCount(
                      //                 crossAxisCount: 4,
                      //                 crossAxisSpacing: 2.0,
                      //                 mainAxisSpacing: 2.0,
                      //                 childAspectRatio: 1.0,
                      //               ),
                      //               itemCount: imageList.length,
                      //               itemBuilder: (context, index) {
                      //                 final imageData = imageList[index].data;
                      //                 return Container(
                      //                   width: itemWidth,
                      //                   height: itemWidth,
                      //                   decoration: BoxDecoration(
                      //                     border: Border.all(
                      //                       color: imageData != null
                      //                           ? Colors.white
                      //                           : Colors.transparent,
                      //                       width: 1.0,
                      //                     ),
                      //                     color: imageData == null
                      //                         ? Colors.grey[200]
                      //                         : null, // Placeholder color for no image
                      //                   ),
                      //                   child: imageData != null
                      //                       ? ImageWithDelete(
                      //                           imageData: imageData,
                      //                           width: itemWidth,
                      //                           height: itemWidth,
                      //                           onDelete: () => viewModel
                      //                               .deleteImage(false, index),
                      //                         )
                      //                       : Center(
                      //                           child: Icon(
                      //                             Icons.add_a_photo,
                      //                             color: Colors.grey[600],
                      //                           ),
                      //                         ),
                      //                 );
                      //               },
                      //             ),
                      //           ),
                      //           const SizedBox(height: 10.0),
                      //           if (imageList.length >= 4)
                      //             Center(
                      //               child: Container(
                      //                 padding: const EdgeInsets.symmetric(
                      //                     vertical: 10.0),
                      //                 child: Text(
                      //                   'Max images have been added',
                      //                   style: TextStyle(
                      //                     color: Colors.grey[600],
                      //                     fontWeight: FontWeight.bold,
                      //                   ),
                      //                 ),
                      //               ),
                      //             )
                      //           else
                      //             Center(
                      //               child: CustomButton(
                      //                 text: 'Add Additional Image',
                      //                 onPressed: () =>
                      //                     viewModel.pickImage(false),
                      //               ),
                      //             ),
                      //         ],
                      //       );
                      //     },
                      //   ),
                      // ),
                      if (viewModel.errorFound)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Main image is required',
                            style: TextStyle(color: AppColors.warningColor),
                          ),
                        ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: viewModel.nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
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
                            return 'Please enter a product name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      TextFormField(
                        controller: viewModel.descriptionController,
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
                            borderSide:
                                BorderSide(color: AppColors.warningColor),
                          ),
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
                            borderSide:
                                BorderSide(color: AppColors.warningColor),
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
                        style:
                            const TextStyle(fontSize: 12, color: Colors.black),
                      ),
                      const SizedBox(height: 40),
                      Align(
                        alignment: Alignment.center,
                        child: CustomButton(
                          text: 'Add Product',
                          onPressed: () async {
                            bool success = await viewModel
                                .addProductWithValidation(context);
                            if (success) {
                              onProductAdded(); // Notify the UI or perform any callback.
                              viewModel
                                  .clearData(); // Clear the ViewModel data after success.

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProductDetailsView(
                                        productId: viewModel.selectedProductId,
                                        isNew: true)),
                              );
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
      }),
    );
  }
}
