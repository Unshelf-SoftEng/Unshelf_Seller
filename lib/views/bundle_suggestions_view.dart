import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/bundle_viewmodel.dart';
import 'package:unshelf_seller/views/add_bundle_view.dart';

class BundleSuggestionsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Bundle Suggestions'),
      ),
      body: Consumer<BundleViewModel>(
        builder: (context, viewModel, child) {
          return FutureBuilder<void>(
            future: viewModel.getSuggestions(), // Use the stored future
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              // Check if data is loaded and not empty
              if (snapshot.connectionState == ConnectionState.done &&
                  viewModel.suggestions.isEmpty) {
                return Center(child: Text('No suggestions available'));
              }

              // Limit to 3 suggestions
              final suggestions = viewModel.suggestions.take(3).toList();

              print('Suggestions passed to the view: $suggestions');

              return ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];

                  // Create a string of product names
                  final productNames = suggestion.products
                      ?.map((product) => product.name)
                      .join(', ');

                  return ListTile(
                    title: Text(suggestion.name),
                    subtitle: Text('Products: $productNames'),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddBundleView(
                            bundle: suggestion,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
