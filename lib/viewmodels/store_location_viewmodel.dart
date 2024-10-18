import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:unshelf_seller/services/permission_service.dart';

class StoreLocationViewModel extends ChangeNotifier {
  LatLng _chosenLocation = LatLng(10.3157, 123.8854);

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
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    try {
      await FirebaseFirestore.instance.collection('stores').doc(user.uid).set({
        'latitude': _chosenLocation.latitude,
        'longitude': _chosenLocation.longitude,
      }, SetOptions(merge: true));
    } catch (error) {
      throw Exception('Failed to save location: $error');
    }

    notifyListeners();
  }
}
