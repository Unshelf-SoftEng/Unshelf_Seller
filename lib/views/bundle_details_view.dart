import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/bundle_viewmodel.dart';
import 'package:unshelf_seller/models/bundle_model.dart';
import 'package:unshelf_seller/utils/colors.dart';

class BundleDetailsView extends StatefulWidget {
  final String bundleId;

  const BundleDetailsView({super.key, required this.bundleId});

  @override
  State<BundleDetailsView> createState() => _BundleDetailsViewState();
}

class _BundleDetailsViewState extends State<BundleDetailsView> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<BundleViewModel>().getBundleDetails(widget.bundleId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bundle Details'),
        backgroundColor: AppColors.palmLeaf,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.deepMossGreen,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: AppColors.lightGreen,
            height: 4.0,
          ),
        ),
      ),
      body: Consumer<BundleViewModel>(
        builder: (context, viewModel, child) {
          final BundleModel? bundle = viewModel.bundle;

          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (bundle == null) {
            return const Center(child: Text('Bundle not found.'));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bundle Image
                  Center(
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.network(
                          bundle.mainImageUrl,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        )),
                  ),
                  const SizedBox(height: 20),

                  // Name and Description
                  _buildDetailCard('Name', bundle.name),
                  _buildDetailCard('Description', bundle.description),
                  _buildDetailCard('Category', bundle.category),
                  _buildDetailCard('Price', bundle.price.toString()),
                  _buildDetailCard('Stock', bundle.stock.toString()),
                  _buildDetailCard('Discount', '${bundle.discount}%'),

                  // Product List
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'Products',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.palmLeaf,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  ...bundle.items.map((item) {
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF6A994E),
                          child: Text(
                            item['quantity'].toString(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          item['name'].toString(),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          'x ${item['quantity']} ${item['quantifier']}',
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            if (title != 'Price')
              Expanded(
                flex: 2,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              )
            else
              Expanded(
                flex: 2,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                    children: [
                      const TextSpan(
                        text: '\u20B1 ', // Peso symbol
                        style: TextStyle(
                          fontFamily: 'Roboto',
                        ),
                      ),
                      TextSpan(
                        text: value,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
