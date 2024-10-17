import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:unshelf_seller/viewmodels/store_location_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/models/store_model.dart';

class EditStoreLocationView extends StatefulWidget {
  final StoreModel storeDetails;

  EditStoreLocationView({required this.storeDetails});

  @override
  _EditStoreLocationViewState createState() => _EditStoreLocationViewState();
}

class _EditStoreLocationViewState extends State<EditStoreLocationView> {
  late StoreLocationViewModel viewModel;
  late StoreModel storeDetails;

  @override
  void initState() {
    super.initState();
    storeDetails = widget.storeDetails;
    viewModel = Provider.of<StoreLocationViewModel>(context, listen: false);
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    if (storeDetails.storeLatitude == null ||
        storeDetails.storeLatitude == 0.0 ||
        storeDetails.storeLongitude == null ||
        storeDetails.storeLongitude == 0.0) {
      Position position = await _getUserLocation();
      setState(() {
        storeDetails.storeLatitude = position.latitude;
        storeDetails.storeLongitude = position.longitude;
      });
    }
  }

  Future<Position> _getUserLocation() async {
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              try {
                await viewModel.saveLocation();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Location saved successfully!')),
                );
                Navigator.pop(context, true);
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
          target: storeDetails.storeLatitude != null &&
                  storeDetails.storeLongitude != null
              ? LatLng(
                  storeDetails.storeLatitude!,
                  storeDetails.storeLongitude!,
                )
              : const LatLng(1.3521, 103.8198),
          zoom: 15,
        ),
        onMapCreated: viewModel.setMapController,
        onTap: (LatLng location) {
          viewModel.updateLocation(location);
        },
        markers: {
          Marker(
            markerId: const MarkerId('chosen_location'),
            position: LatLng(
              storeDetails.storeLatitude ?? 1.3521,
              storeDetails.storeLongitude ?? 103.8198,
            ),
            draggable: true,
            onDragEnd: (LatLng newPosition) {
              viewModel.updateLocation(newPosition);
            },
          ),
        },
      ),
    );
  }
}
