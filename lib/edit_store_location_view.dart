import 'dart:js' as js;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/models/store_model.dart';

class EditStoreLocationScreen extends StatefulWidget {
  final StoreModel userProfile;

  EditStoreLocationScreen({required this.userProfile, Key? key})
      : super(key: key);

  @override
  _EditStoreLocationScreenState createState() =>
      _EditStoreLocationScreenState();
}

class _EditStoreLocationScreenState extends State<EditStoreLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  late LatLng _currentLocation;

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.userProfile.storeLocation != null
        ? LatLng(
            double.parse(widget.userProfile.storeLocation!.split(',')[0]),
            double.parse(widget.userProfile.storeLocation!.split(',')[1]),
          )
        : LatLng(0.0, 0.0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMap();
    });
  }

  void _initializeMap() {
    js.context.callMethod('initMap');
    js.context.callMethod('window.marker.setPosition', [
      js.JsObject.jsify(
          {'lat': _currentLocation.latitude, 'lng': _currentLocation.longitude})
    ]);
    js.context.callMethod('window.map.setCenter', [
      js.JsObject.jsify(
          {'lat': _currentLocation.latitude, 'lng': _currentLocation.longitude})
    ]);
  }

  void _updateStoreLocation() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'storeLocation':
              '${_currentLocation.latitude},${_currentLocation.longitude}'
        });

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update location: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Store Location'),
      ),
      body: Column(
        children: [
          Container(
            height: 500.0,
            width: double.infinity,
            child: HtmlElementView(
              viewType: 'google-maps',
              onPlatformViewCreated: (viewId) {
                // Handle platform-specific setup if needed
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text('Selected Location:'),
                  Text(
                      '${_currentLocation.latitude}, ${_currentLocation.longitude}'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updateStoreLocation,
                    child: Text('Save Changes'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
