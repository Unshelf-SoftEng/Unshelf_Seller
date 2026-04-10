import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:unshelf_seller/core/constants/firestore_constants.dart';
import 'package:unshelf_seller/core/current_user_provider.dart';
import 'package:unshelf_seller/core/errors/app_exceptions.dart';
import 'package:unshelf_seller/core/interfaces/i_bundle_service.dart';
import 'package:unshelf_seller/core/logger.dart';
import 'package:unshelf_seller/models/bundle_model.dart';

class BundleService implements IBundleService {
  final FirebaseFirestore _firestore;
  final CurrentUserProvider _currentUser;

  BundleService({
    FirebaseFirestore? firestore,
    CurrentUserProvider? currentUser,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _currentUser = currentUser ?? CurrentUserProvider();

  @override
  Future<BundleModel?> getBundle(String bundleId) async {
    try {
      final bundleDoc = await _firestore
          .collection(FirestoreConstants.bundles)
          .doc(bundleId)
          .get();

      if (bundleDoc.exists) {
        return BundleModel.fromSnapshot(bundleDoc);
      }

      return null;
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to fetch bundle', e, stackTrace);
      throw FirestoreException('Failed to fetch bundle', originalError: e);
    }
  }

  @override
  Future<List<BundleModel>> getBundles() async {
    try {
      final bundleDocs = await _firestore
          .collection(FirestoreConstants.bundles)
          .where(FirestoreConstants.sellerId, isEqualTo: _currentUser.uid)
          .get();

      return bundleDocs.docs
          .map((doc) => BundleModel.fromSnapshot(doc))
          .toList();
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to fetch bundles', e, stackTrace);
      throw FirestoreException('Failed to fetch bundles', originalError: e);
    }
  }

  @override
  Future<void> createBundle(BundleModel bundle) async {
    try {
      await _firestore.collection(FirestoreConstants.bundles).add({
        ...bundle.toMap(),
        FirestoreConstants.sellerId: _currentUser.uid,
        'isListed': true,
      });
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to create bundle', e, stackTrace);
      throw FirestoreException('Failed to create bundle', originalError: e);
    }
  }

  @override
  Future<void> updateBundle(BundleModel bundle) async {
    try {
      await _firestore
          .collection(FirestoreConstants.bundles)
          .doc(bundle.id)
          .update(bundle.toMap());
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to update bundle', e, stackTrace);
      throw FirestoreException('Failed to update bundle', originalError: e);
    }
  }

  @override
  Future<void> deleteBundle(String bundleId) async {
    try {
      await _firestore
          .collection(FirestoreConstants.bundles)
          .doc(bundleId)
          .delete();
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to delete bundle', e, stackTrace);
      throw FirestoreException('Failed to delete bundle', originalError: e);
    }
  }
}
