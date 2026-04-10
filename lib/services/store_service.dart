import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:unshelf_seller/core/constants/firestore_constants.dart';
import 'package:unshelf_seller/core/current_user_provider.dart';
import 'package:unshelf_seller/core/errors/app_exceptions.dart';
import 'package:unshelf_seller/core/interfaces/i_store_service.dart';
import 'package:unshelf_seller/core/logger.dart';
import 'package:unshelf_seller/models/store_model.dart';
import 'package:unshelf_seller/models/user_model.dart';

class StoreService implements IStoreService {
  final FirebaseFirestore _firestore;
  final CurrentUserProvider _currentUser;

  StoreService({
    FirebaseFirestore? firestore,
    CurrentUserProvider? currentUser,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _currentUser = currentUser ?? CurrentUserProvider();

  @override
  Future<UserProfileModel?> fetchUserProfile() async {
    try {
      final uid = _currentUser.uid;

      final userDoc = await _firestore
          .collection(FirestoreConstants.users)
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        AppLogger.warning('User profile not found for uid: $uid');
        return null;
      }

      return UserProfileModel.fromSnapshot(userDoc);
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to fetch user profile', e, stackTrace);
      throw FirestoreException('Failed to fetch user profile', originalError: e);
    }
  }

  @override
  Future<StoreModel?> fetchStoreDetails() async {
    try {
      final uid = _currentUser.uid;

      final userDoc = await _firestore
          .collection(FirestoreConstants.users)
          .doc(uid)
          .get();

      final storeDoc = await _firestore
          .collection(FirestoreConstants.stores)
          .doc(uid)
          .get();

      if (!userDoc.exists || !storeDoc.exists) {
        AppLogger.warning('User profile or store not found for uid: $uid');
        return null;
      }

      AppLogger.debug('Store details fetched for uid: $uid');
      return StoreModel.fromSnapshot(userDoc, storeDoc);
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to fetch store details', e, stackTrace);
      throw FirestoreException('Failed to fetch store details', originalError: e);
    }
  }

  @override
  Future<int> fetchStoreFollowers() async {
    try {
      final uid = _currentUser.uid;

      final followersSnapshot = await _firestore
          .collection(FirestoreConstants.stores)
          .doc(uid)
          .collection('followers')
          .get();

      AppLogger.debug('Store followers fetched: ${followersSnapshot.size}');
      return followersSnapshot.size;
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to fetch store followers', e, stackTrace);
      throw FirestoreException('Failed to fetch store followers',
          originalError: e);
    }
  }

  @override
  Future<double> fetchStoreRatings() async {
    try {
      final uid = _currentUser.uid;

      final ratingsSnapshot = await _firestore
          .collection(FirestoreConstants.stores)
          .doc(uid)
          .collection('ratings')
          .doc('average')
          .get();

      final rawData = ratingsSnapshot.data();
      final Map<String, dynamic>? data =
          rawData != null ? Map<String, dynamic>.from(rawData as Map) : null;
      final average = (data?['average'] ?? 0.0).toDouble();

      AppLogger.debug('Store rating fetched: $average');
      return average;
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to fetch store ratings', e, stackTrace);
      throw FirestoreException('Failed to fetch store ratings', originalError: e);
    }
  }

  @override
  Future<void> updateStoreProfile(Map<String, dynamic> fields) async {
    try {
      final uid = _currentUser.uid;

      await _firestore
          .collection(FirestoreConstants.stores)
          .doc(uid)
          .update(fields);

      AppLogger.debug('Store profile updated for uid: $uid');
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to update store profile', e, stackTrace);
      throw FirestoreException('Failed to update store profile', originalError: e);
    }
  }

  @override
  Future<void> saveStoreLocation(double latitude, double longitude) async {
    try {
      final uid = _currentUser.uid;

      await _firestore
          .collection(FirestoreConstants.stores)
          .doc(uid)
          .set({
        'latitude': latitude,
        'longitude': longitude,
      }, SetOptions(merge: true));

      AppLogger.debug('Store location saved for uid: $uid');
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to save store location', e, stackTrace);
      throw FirestoreException('Failed to save store location', originalError: e);
    }
  }

  @override
  Future<void> saveStoreSchedule(
      String userId, Map<String, Map<String, dynamic>> schedule) async {
    try {
      await _firestore
          .collection(FirestoreConstants.stores)
          .doc(userId)
          .update({
        'storeSchedule': schedule,
      });

      AppLogger.debug('Store schedule saved for uid: $userId');
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to save store schedule', e, stackTrace);
      throw FirestoreException('Failed to save store schedule', originalError: e);
    }
  }
}
