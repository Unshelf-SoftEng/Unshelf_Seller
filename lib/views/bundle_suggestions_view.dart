import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/bundle_suggestion_viewmodel.dart';
import 'package:unshelf_seller/components/custom_app_bar.dart';

class BundleSuggestionsView extends StatelessWidget {
  const BundleSuggestionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Bundle Suggestions',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Consumer<BundleSuggestionViewModel>(
        builder: (context, viewModel, child) {
          return FutureBuilder<void>(
            future: viewModel.fetchSuggestions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.done &&
                  viewModel.suggestions.isEmpty) {
                return const Center(child: Text('No suggestions available'));
              }

              final suggestions = viewModel.suggestions.take(3).toList();

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = suggestions[index];
                    // Create a string of product names
                    final productNames = suggestion.products
                        ?.map((product) => product.name)
                        .join(', ');

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        title: Text(
                          suggestion.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'Products: $productNames',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Theme.of(context).primaryColor,
                        ),
                        onTap: () {
                          // Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => AddBundleView(
                          //     ),
                          //   ),
                          // );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
