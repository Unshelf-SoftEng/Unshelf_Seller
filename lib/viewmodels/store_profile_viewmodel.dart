import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unshelf_seller/core/base_viewmodel.dart';
import 'package:unshelf_seller/core/interfaces/i_store_service.dart';
import 'package:unshelf_seller/models/store_model.dart';

class StoreProfileViewModel extends BaseViewModel {
  final IStoreService _storeService;
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneNumberController;
  Uint8List? _profileImage;
  final ImagePicker picker = ImagePicker();

  StoreProfileViewModel(StoreModel storeDetails,
      {required IStoreService storeService})
      : _storeService = storeService {
    _nameController = TextEditingController(text: storeDetails.storeName);
    _addressController = TextEditingController(text: storeDetails.storeAddress);
    _phoneNumberController =
        TextEditingController(text: storeDetails.storePhoneNumber);
  }

  TextEditingController get nameController => _nameController;
  Uint8List? get profileImage => _profileImage;

  Future<void> pickImage() async {
    XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final Uint8List imageData = await image.readAsBytes();
      _profileImage = imageData;
      notifyListeners();
    }
  }

  Future<void> updateStoreProfile() async {
    if (_nameController.text.isNotEmpty) {
      await runBusyFuture(() async {
        final updateData = <String, dynamic>{
          'storeName': _nameController.text,
        };

        if (_addressController.text.isNotEmpty) {
          updateData['storeAddress'] = _addressController.text;
        }

        if (_phoneNumberController.text.isNotEmpty) {
          updateData['storePhoneNumber'] = _phoneNumberController.text;
        }

        if (_profileImage != null) {
          final imageUrl = await uploadImage(_profileImage!);
          updateData['storeImageUrl'] = imageUrl;
        }

        await _storeService.updateStoreProfile(updateData);
        notifyListeners();
      });
    }
  }

  Future<String> uploadImage(Uint8List? image) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final mainImageRef =
        FirebaseStorage.instance.ref().child('user_avatars/$userId.jpg');
    await mainImageRef.putData(image!);
    final mainImageUrl = await mainImageRef.getDownloadURL();
    return mainImageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
