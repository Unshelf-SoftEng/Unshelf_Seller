import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/models/store_model.dart';

class EditStoreProfileViewModel extends ChangeNotifier {
  final String storeId; // The ID of the store to update
  late TextEditingController _nameController;
  Uint8List? _profileImage;
  bool _isLoading = false;

  EditStoreProfileViewModel(StoreModel storeDetails)
      : storeId = storeDetails.userId {
    _nameController = TextEditingController(text: storeDetails.storeName);
    _profileImage = storeDetails.storeImageUrl != null
        ? NetworkImage(storeDetails.storeImageUrl!) as Uint8List
        : null;
  }

  TextEditingController get nameController => _nameController;
  Uint8List? get profileImage => _profileImage;
  bool get isLoading => _isLoading;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      _profileImage = imageBytes;
      notifyListeners();
    }
  }

  Future<void> updateStoreProfile() async {
    if (_nameController.text.isNotEmpty) {
      _setLoading(true);
      try {
        // Update store details in Firestore
        final storeRef =
            FirebaseFirestore.instance.collection('stores').doc(storeId);
        final updateData = {
          'store_name': _nameController.text,
          // Handle image upload if a new image is selected
        };

        if (_profileImage != null) {
          // Assuming you have a method to upload the image and get the URL
          final imageUrl = await uploadImage(_profileImage!);
          updateData['store_profile_picture_url'] = imageUrl;
        }

        await storeRef.update(updateData);
        notifyListeners(); // Notify listeners if necessary
      } catch (e) {
        // Handle errors
        print('Error updating store profile: $e');
      } finally {
        _setLoading(false);
      }
    }
  }

  Future<String> uploadImage(Uint8List imageBytes) async {
    // Your image upload logic here, such as using Firebase Storage
    // Return the URL of the uploaded image
    return 'https://example.com/image-url';
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
