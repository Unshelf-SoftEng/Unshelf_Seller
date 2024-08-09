// views/edit_store_location_view.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/store_location_viewmodel.dart';

class EditStoreLocationView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StoreLocationViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Choose a Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              try {
                await viewModel.saveLocation();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Location saved successfully!')),
                );
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to save location: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: viewModel.chosenLocation,
          zoom: 13,
        ),
        onMapCreated: viewModel.setMapController,
        onTap: (LatLng location) {
          viewModel.updateLocation(location);
        },
        markers: {
          Marker(
            markerId: MarkerId('chosen_location'),
            position: viewModel.chosenLocation,
          ),
        },
      ),
    );
  }
}
