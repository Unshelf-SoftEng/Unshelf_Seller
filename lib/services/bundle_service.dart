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
  Future<void> createBundle(BundleModel bundle) async {
    try {
      final bundleData = {
        'name': bundle.name,
        'category': bundle.category,
        'description': bundle.description,
        'items': bundle.items,
        FirestoreConstants.price: bundle.price,
        FirestoreConstants.stock: bundle.stock,
        FirestoreConstants.discount: bundle.discount,
        'mainImageUrl': bundle.mainImageUrl,
        FirestoreConstants.sellerId: _currentUser.uid,
        'isListed': true,
      };

      await _firestore.collection(FirestoreConstants.bundles).add(bundleData);
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to create bundle', e, stackTrace);
      throw FirestoreException('Failed to create bundle', originalError: e);
    }
  }

  @override
  Future<void> updateBundle(BundleModel bundle) async {
    try {
      final bundleData = {
        'name': bundle.name,
        'category': bundle.category,
        'description': bundle.description,
        'items': bundle.items,
        FirestoreConstants.price: bundle.price,
        FirestoreConstants.stock: bundle.stock,
        FirestoreConstants.discount: bundle.discount,
        'mainImageUrl': bundle.mainImageUrl,
      };

      await _firestore
          .collection(FirestoreConstants.bundles)
          .doc(bundle.id)
          .update(bundleData);
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to update bundle', e, stackTrace);
      throw FirestoreException('Failed to update bundle', originalError: e);
    }
  }
}
