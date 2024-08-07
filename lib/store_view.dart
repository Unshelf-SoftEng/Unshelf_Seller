// store_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unshelf_seller/viewmodels/store_viewmodel.dart';
import 'package:unshelf_seller/edit_store_schedule_view.dart';
import 'package:unshelf_seller/edit_store_location_view.dart';

class StoreView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StoreViewModel>(context);

    // Hardcoded values for store ratings and number of followers
    final double storeRating = 4.5;
    final int numberOfFollowers = 1200;

    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.storeDetails?.storeName ?? 'Store View'),
      ),
      body: viewModel.isLoading
          ? Center(child: CircularProgressIndicator())
          : viewModel.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(viewModel.errorMessage!),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          viewModel.fetchStoreDetails();
                        },
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Store Name: ${viewModel.storeDetails?.storeName ?? 'N/A'}',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Store Rating: $storeRating',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Followers: $numberOfFollowers',
                        style: TextStyle(fontSize: 16),
                      ),
                      // Add more store details here as needed
                    ],
                  ),
                ),
    );
  }
}
