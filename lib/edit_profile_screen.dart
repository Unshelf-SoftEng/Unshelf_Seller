import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile userProfile;

  EditProfileScreen({required this.userProfile});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _storeHoursController;
  late TextEditingController _storeLocationController;

  @override
  void initState() {
    super.initState();
    _storeHoursController =
        TextEditingController(text: widget.userProfile.storeHours ?? '');
    _storeLocationController =
        TextEditingController(text: widget.userProfile.storeLocation ?? '');
  }

  @override
  void dispose() {
    _storeHoursController.dispose();
    _storeLocationController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      // Update user profile in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userProfile.email)
          .update({
        'store_hours': _storeHoursController.text,
        'store_location': _storeLocationController.text,
      });
      Navigator.pop(context); // Return to the profile screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Store Hours'),
                controller: _storeHoursController,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Store Location'),
                controller: _storeLocationController,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
