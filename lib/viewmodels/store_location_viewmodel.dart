import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:unshelf_seller/core/base_viewmodel.dart';
import 'package:unshelf_seller/core/interfaces/i_store_service.dart';
import 'package:unshelf_seller/services/permission_service.dart';

class StoreLocationViewModel extends BaseViewModel {
  final IStoreService _storeService;

  StoreLocationViewModel({required IStoreService storeService})
      : _storeService = storeService;

  LatLng _chosenLocation = const LatLng(10.3157, 123.8854);

  LatLng get chosenLocation => _chosenLocation;

  void updateLocation(LatLng location) {
    _chosenLocation = location;
    notifyListeners();
  }

  Future<Position?> getUserLocation(BuildContext context) async {
    // Request location permission
    await requestLocationPermission();

    // Check if permission is granted
    var status = await Permission.location.status;
    if (status.isGranted) {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } else if (status.isDenied) {
      String message =
          'Location permission is required to use this feature. Please enable it in settings.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return null;
    } else if (status.isPermanentlyDenied) {
      // Permission is permanently denied
      String message =
          'Location permission is permanently denied. Please enable it in app settings.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () {
              openAppSettings();
            },
          ),
        ),
      );
      return null;
    }

    return null;
  }

  Future<void> saveLocation() async {
    await runBusyFuture(() async {
      await _storeService.saveStoreLocation(
        _chosenLocation.latitude,
        _chosenLocation.longitude,
      );
    });
    notifyListeners();
  }
}
