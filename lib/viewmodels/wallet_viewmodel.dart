import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/models/order_model.dart';

class Transaction {
  final String type; // "withdraw" or "add"
  final double amount;
  final DateTime date;

  Transaction({required this.type, required this.amount, required this.date});
}

class WalletViewModel extends ChangeNotifier {
  double _balance = 100.0; // Initial balance for demonstration purposes
  String _error = '';
  List<Transaction> _transactions = [];

  double get balance => _balance;
  void set balance(double value) => _balance = value;
  String get error => _error;
  List<Transaction> get transactions => _transactions;
  void set transactions(List<Transaction> value) => _transactions = value;

  WalletViewModel() {
    _initializeDummyData(); // Load dummy data on initialization\
    updateBalanceFromTransactions();
  }

  void _initializeDummyData() {
    transactions = [
      Transaction(
          type: 'withdraw',
          amount: 500, // More realistic withdrawal
          date: DateTime.parse('2024-09-28 14:30:00')),
      Transaction(
          type: 'sale',
          amount: 53.75,
          date: DateTime.parse('2024-09-27 09:15:00')),
      Transaction(
          type: 'sale',
          amount: 72.30,
          date: DateTime.parse('2024-09-26 18:45:00')),
      Transaction(
          type: 'sale',
          amount: 118.90,
          date: DateTime.parse('2024-09-25 11:00:00')),
      Transaction(
          type: 'sale',
          amount: 92.15,
          date: DateTime.parse('2024-09-23 08:00:00')),
      Transaction(
          type: 'sale',
          amount: 113.40,
          date: DateTime.parse('2024-09-22 19:15:00')),
      Transaction(
          type: 'sale',
          amount: 61.85,
          date: DateTime.parse('2024-09-21 10:45:00')),
      Transaction(
          type: 'sale',
          amount: 45.20,
          date: DateTime.parse('2024-09-20 15:30:00')),
      Transaction(
          type: 'sale',
          amount: 82.50,
          date: DateTime.parse('2024-09-19 12:00:00')),
    ];
    notifyListeners(); // Notify listeners to update UI
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
  void updateBalanceFromTransactions() {
    double newBalance = 0.0;
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
