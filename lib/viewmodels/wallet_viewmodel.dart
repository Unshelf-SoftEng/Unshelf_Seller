import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

class WalletViewModel extends ChangeNotifier {
  double _balance = 0;
  String _error = '';
  List<Transaction> _transactions = [];

  double get balance => _balance;
  String get error => _error;
  List<Transaction> get transactions => _transactions;

  WalletViewModel() {
    updateTransactions();
  }

  Future<void> withdrawFunds(double amount) async {
    if (amount <= 0) {
      _error = 'Amount must be greater than zero';
      notifyListeners();
      return;
    }

    if (amount > _balance) {
      _error = 'Insufficient funds';
      notifyListeners();
      return;
    }

    // Deduct the amount from the balance
    _balance -= amount;

    // Add the withdrawal transaction to the local list
    _transactions.add(Transaction(
      type: 'withdraw',
      amount: amount,
      date: DateTime.now(),
    ));

    _error = '';
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _error = 'User not logged in';
      notifyListeners();
      return; // Early return if user is not logged in
    }

    try {
      // Save the withdrawal transaction to Firestore
      await FirebaseFirestore.instance.collection('transactions').add({
        'sellerId': user.uid,
        'amount': amount,
        'type': 'withdraw', // Ensure the type is 'withdraw'
        'date': FieldValue
            .serverTimestamp(), // Use server timestamp for consistency
      });
    } catch (e) {
      // Handle Firestore errors here
      _error = 'Error saving transaction: $e';
      notifyListeners();
    }
  }

  // Method to update balance based on the transactions
  Future<void> updateTransactions() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    // Fetch transactions for the current seller
    final querySnapshot = await FirebaseFirestore.instance
        .collection('transactions') // Your transactions collection
        .where('sellerId', isEqualTo: user.uid) // Use the actual field name
        .orderBy('date', descending: true)
        .get();

    // Clear existing transactions
    _transactions.clear();

    double newBalance = 0.0;

    for (var doc in querySnapshot.docs) {
      // Get the required fields from Firestore
      String orderId = doc['orderId']; // Assuming you'll use this in your app
      double sellerEarnings =
          doc['sellerEarnings'].toDouble(); // Ensure it is a double
      DateTime date =
          (doc['date'] as Timestamp).toDate(); // Convert Timestamp to DateTime

      print('Order Id' + orderId);

      print('Seller Earnings' + sellerEarnings.toString());

      // Add the sale transaction to the list
      _transactions.add(Transaction(
          type: 'sale', amount: sellerEarnings, date: date, orderId: orderId));

      // Update the balance
      newBalance += sellerEarnings; // Increase balance with seller earnings
    }

    // Fetch withdrawal transactions and update balance
    final withdrawalSnapshot = await FirebaseFirestore.instance
        .collection('transactions') // Your transactions collection
        .where('sellerId', isEqualTo: user.uid) // Use the actual field name
        .where('type',
            isEqualTo: 'withdraw') // Only fetch withdrawal transactions
        .get();

    for (var doc in withdrawalSnapshot.docs) {
      double withdrawalAmount =
          doc['amount'].toDouble(); // Ensure it is a double
      newBalance -= withdrawalAmount; // Decrease balance with withdrawal amount

      // Add the withdrawal transaction to the list
      _transactions.add(Transaction(
        type: 'withdraw',
        amount: withdrawalAmount,
        date: (doc['date'] as Timestamp)
            .toDate(), // Assuming you also have date for withdrawals
      ));
    }

    // Update the balance after fetching transactions
    _balance =
        newBalance; // Final balance after considering both earnings and withdrawals
    notifyListeners();
  }
}
