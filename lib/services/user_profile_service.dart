import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:unshelf_seller/core/constants/firestore_constants.dart';
import 'package:unshelf_seller/core/current_user_provider.dart';
import 'package:unshelf_seller/core/errors/app_exceptions.dart';
import 'package:unshelf_seller/core/interfaces/i_user_profile_service.dart';
import 'package:unshelf_seller/core/logger.dart';
import 'package:unshelf_seller/models/user_model.dart';

class UserProfileService implements IUserProfileService {
  final FirebaseFirestore _firestore;
  final CurrentUserProvider _currentUser;

  UserProfileService({
    FirebaseFirestore? firestore,
    CurrentUserProvider? currentUser,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _currentUser = currentUser ?? CurrentUserProvider();

  @override
  Future<UserProfileModel?> getUserProfile() async {
    try {
      final uid = _currentUser.uid;

      final doc = await _firestore
          .collection(FirestoreConstants.users)
          .doc(uid)
          .get();

      if (!doc.exists) {
        AppLogger.debug('No user profile found for uid: $uid');
        return null;
      }

      AppLogger.debug('User profile fetched for uid: $uid');

      return UserProfileModel.fromSnapshot(doc);
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to fetch user profile', e, stackTrace);
      throw FirestoreException('Failed to fetch user profile',
          originalError: e);
    }
  }

  @override
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final uid = _currentUser.uid;

      await _firestore
          .collection(FirestoreConstants.users)
          .doc(uid)
          .update(data);

      AppLogger.debug('User profile updated for uid: $uid');
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to update user profile', e, stackTrace);
      throw FirestoreException('Failed to update user profile',
          originalError: e);
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserDocument(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirestoreConstants.users)
          .doc(uid)
          .get();

      if (!doc.exists) {
        AppLogger.debug('No user document found for uid: $uid');
        return null;
      }

      AppLogger.debug('User document fetched for uid: $uid');

      return doc.data();
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to fetch user document', e, stackTrace);
      throw FirestoreException('Failed to fetch user document',
          originalError: e);
    }
  }

  @override
  Future<void> createUserDocument(
      String uid, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(FirestoreConstants.users)
          .doc(uid)
          .set(data);

      AppLogger.debug('User document created for uid: $uid');
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to create user document', e, stackTrace);
      throw FirestoreException('Failed to create user document',
          originalError: e);
    }
  }
}
