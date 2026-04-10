import 'package:unshelf_seller/models/user_model.dart';

abstract class IUserProfileService {
  Future<UserProfileModel?> getUserProfile();
  Future<void> updateUserProfile(Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getUserDocument(String uid);
  Future<void> createUserDocument(String uid, Map<String, dynamic> data);
}
