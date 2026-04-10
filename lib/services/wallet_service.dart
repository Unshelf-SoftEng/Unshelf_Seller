import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:unshelf_seller/core/constants/firestore_constants.dart';
import 'package:unshelf_seller/core/constants/status_constants.dart';
import 'package:unshelf_seller/core/current_user_provider.dart';
import 'package:unshelf_seller/core/errors/app_exceptions.dart';
import 'package:unshelf_seller/core/interfaces/i_wallet_service.dart';
import 'package:unshelf_seller/core/logger.dart';

class WalletService implements IWalletService {
  final FirebaseFirestore _firestore;
  final CurrentUserProvider _currentUser;

  WalletService({
    FirebaseFirestore? firestore,
    CurrentUserProvider? currentUser,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _currentUser = currentUser ?? CurrentUserProvider();

  @override
  Future<void> submitWithdrawalRequest({
    required double amount,
    required String accountName,
    required String bankName,
    required String bankAccount,
  }) async {
    try {
      final uid = _currentUser.uid;

      await _firestore.collection(FirestoreConstants.withdrawalRequests).add({
        'sellerId': uid,
        'amount': amount,
        'date': FieldValue.serverTimestamp(),
        'bankName': bankName,
        'accountName': accountName,
        'bankAccount': bankAccount,
        'isApproved': false,
      });

      await _firestore.collection(FirestoreConstants.transactions).add({
        'sellerId': uid,
        'amount': amount,
        'type': StatusConstants.withdraw,
        'date': FieldValue.serverTimestamp(),
      });

      AppLogger.debug('Withdrawal request submitted for uid: $uid');
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to submit withdrawal request', e, stackTrace);
      throw FirestoreException('Failed to submit withdrawal request',
          originalError: e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAllTransactions() async {
    try {
      final uid = _currentUser.uid;

      final querySnapshot = await _firestore
          .collection(FirestoreConstants.transactions)
          .where(FirestoreConstants.sellerId, isEqualTo: uid)
          .orderBy('date', descending: true)
          .get();

      AppLogger.debug('Transactions fetched: ${querySnapshot.docs.length}');

      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    } on FirebaseException catch (e, stackTrace) {
      AppLogger.error('Failed to fetch transactions', e, stackTrace);
      throw FirestoreException('Failed to fetch transactions',
          originalError: e);
    }
  }
}
