import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditStoreLocationView extends StatefulWidget {
  @override
  _EditStoreLocationViewState createState() => _EditStoreLocationViewState();
}

class _EditStoreLocationViewState extends State<EditStoreLocationView> {
  late GoogleMapController _mapController;
  LatLng _chosenLocation = LatLng(0, 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose a Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveLocation,
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target:
              LatLng(37.7749, -122.4194), // Default location (San Francisco)
          zoom: 10,
        ),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        onTap: (LatLng location) {
          setState(() {
            _chosenLocation = location;
          });
        },
        markers: {
          Marker(
            markerId: MarkerId('chosen_location'),
            position: _chosenLocation,
          ),
        },
      ),
    );
  }

  void _saveLocation() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User is not logged in')),
      );
      return;
    }

    FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
      'latitude': _chosenLocation.latitude,
      'longitude': _chosenLocation.longitude,
    }, SetOptions(merge: true)).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location saved successfully!')),
      );
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save location: $error')),
      );
    });
  }
}
