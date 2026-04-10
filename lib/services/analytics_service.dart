import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:unshelf_seller/core/constants/firestore_constants.dart';
import 'package:unshelf_seller/core/current_user_provider.dart';
import 'package:unshelf_seller/core/errors/app_exceptions.dart';
import 'package:unshelf_seller/core/interfaces/i_analytics_service.dart';
import 'package:unshelf_seller/core/logger.dart';

class AnalyticsService implements IAnalyticsService {
  final FirebaseFirestore _firestore;
  final CurrentUserProvider _currentUser;

  AnalyticsService({
    FirebaseFirestore? firestore,
    CurrentUserProvider? currentUser,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _currentUser = currentUser ?? CurrentUserProvider();

  @override
  Future<List<QueryDocumentSnapshot>> fetchOrders({DateTime? since}) async {
    try {
      final uid = _currentUser.uid;

      Query query = _firestore
          .collection(FirestoreConstants.orders)
          .where(FirestoreConstants.sellerId, isEqualTo: uid);

      if (since != null) {
        query = query.where(FirestoreConstants.createdAt,
            isGreaterThanOrEqualTo: since);
      }

      final snapshot = await query.get();

      AppLogger.debug('Orders fetched for analytics: ${snapshot.docs.length}');

      return snapshot.docs;
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to fetch orders for analytics', e, stackTrace);
      throw FirestoreException('Failed to fetch orders for analytics',
          originalError: e);
    }
  }

  @override
  Future<List<QueryDocumentSnapshot>> fetchTransactions(
      {DateTime? since}) async {
    try {
      final uid = _currentUser.uid;

      Query query = _firestore
          .collection(FirestoreConstants.transactions)
          .where(FirestoreConstants.sellerId, isEqualTo: uid);

      if (since != null) {
        query = query.where('date', isGreaterThanOrEqualTo: since);
      }

      final snapshot = await query.get();

      AppLogger.debug(
          'Transactions fetched for analytics: ${snapshot.docs.length}');

      return snapshot.docs;
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error(
          'Failed to fetch transactions for analytics', e, stackTrace);
      throw FirestoreException('Failed to fetch transactions for analytics',
          originalError: e);
    }
  }
}
