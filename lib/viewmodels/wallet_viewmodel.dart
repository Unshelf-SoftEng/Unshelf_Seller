import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/models/order_model.dart';

class Transaction {
  final String type; // "withdraw" or "add"
  final double amount;
  final DateTime date;

  Transaction({required this.type, required this.amount, required this.date});
}

class WalletViewModel extends ChangeNotifier {
  double _balance = 0;
  String _error = '';
  List<Transaction> _transactions = [];

  double get balance => _balance;
  void set balance(double value) => _balance = value;
  String get error => _error;
  List<Transaction> get transactions => _transactions;
  void set transactions(List<Transaction> value) => _transactions = value;

  WalletViewModel() {
    updateBalanceFromTransactions();
  }

  // Method to withdraw funds from the wallet
  void withdrawFunds(double amount) {
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

    _balance -= amount;
    _transactions.add(Transaction(
      type: 'withdraw',
      amount: amount,
      date: DateTime.now(),
    ));
    _error = '';
    notifyListeners();
  }

  // Method to update balance based on the transactions
  Future<void> updateBalanceFromTransactions() async {
    double newBalance = 0.0;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('seller_id', isEqualTo: user.uid)
        .where('status', isEqualTo: "Completed")
        .orderBy('created_at', descending: true)
        .get();

    for (var transaction in _transactions) {
      if (transaction.type == 'sale') {
        newBalance += transaction.amount;
      } else if (transaction.type == 'withdraw') {
        newBalance -= transaction.amount;
      }
    }
    _balance = newBalance;
    notifyListeners();
  }
}
