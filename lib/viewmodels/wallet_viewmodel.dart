import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/core/base_viewmodel.dart';
import 'package:unshelf_seller/core/constants/firestore_constants.dart';
import 'package:unshelf_seller/core/constants/status_constants.dart';

class Transaction {
  final String type; // "withdraw" or "sale"
  final double amount; // This reflects the seller earnings or withdrawal amount
  final DateTime date;
  final String? orderId;

  Transaction(
      {required this.type,
      required this.amount,
      required this.date,
      this.orderId});
}

class WalletViewModel extends BaseViewModel {
  double _balance = 0;
  String _walletError = '';
  List<Transaction> _transactions = [];

  double get balance => _balance;
  String get walletError => _walletError;
  List<Transaction> get transactions => _transactions;

  WalletViewModel() {
    updateTransactions();
  }

  Future<void> withdrawRequest(double amount, String accountName,
      String bankName, String bankAccount) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _walletError = 'User not logged in';
      notifyListeners();
      return; // Early return if user is not logged in
    }

    try {
      await FirebaseFirestore.instance
          .collection(FirestoreConstants.withdrawalRequests)
          .add({
        'sellerId': user.uid,
        'amount': amount,
        'date': FieldValue.serverTimestamp(),
        'bankName': bankName,
        'accountName': accountName,
        'bankAccount': bankAccount,
        'isApproved': false,
      });

      await FirebaseFirestore.instance
          .collection(FirestoreConstants.transactions)
          .add({
        'sellerId': user.uid,
        'amount': amount,
        'type': StatusConstants.withdraw,
        'date': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _walletError = 'Error saving transaction: $e';
      notifyListeners();
    }

    _balance -= amount;

    notifyListeners();
  }

  // Method to update balance based on the transactions
  Future<void> updateTransactions() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    // Fetch transactions for the current seller
    final querySnapshot = await FirebaseFirestore.instance
        .collection(FirestoreConstants.transactions) // Your transactions collection
        .where('sellerId', isEqualTo: user.uid)
        .orderBy('date', descending: true)
        .get();

    // Clear existing transactions
    _transactions.clear();

    double newBalance = 0.0;

    for (var doc in querySnapshot.docs) {
      DateTime date = (doc['date'] as Timestamp).toDate();

      if (doc['type'] == StatusConstants.withdraw) {
        double amount = doc['amount'].toDouble();

        _transactions.add(Transaction(
            type: StatusConstants.withdraw,
            amount: amount,
            date: date,
            orderId: 'XXXXXX-XXX'));
        newBalance -= amount;
      } else {
        String orderId = doc['orderId'];

        if (doc['isPaid']) {
          double sellerEarnings = doc['sellerEarnings'].toDouble();

          _transactions.add(Transaction(
              type: StatusConstants.sale,
              amount: sellerEarnings,
              date: date,
              orderId: orderId));

          // Update the balance
          newBalance += sellerEarnings;
        } else {
          double transactionFee = doc['transactionFee'].toDouble();
          _transactions.add(Transaction(
              type: 'Commission Fee',
              amount: transactionFee,
              date: date,
              orderId: orderId));

          // Update the balance
          newBalance -= transactionFee;
        }
      }
    }

    // Fetch withdrawal transactions and update balance
    final withdrawalSnapshot = await FirebaseFirestore.instance
        .collection(FirestoreConstants.transactions)
        .where('sellerId', isEqualTo: user.uid)
        .where('type', isEqualTo: StatusConstants.withdraw)
        .get();

    for (var doc in withdrawalSnapshot.docs) {
      double withdrawalAmount = doc['amount'].toDouble();
      newBalance -= withdrawalAmount;

      _transactions.add(Transaction(
        type: StatusConstants.withdraw,
        amount: withdrawalAmount,
        date: (doc['date'] as Timestamp).toDate(),
      ));
    }

    _balance = newBalance;
    notifyListeners();
  }
}
