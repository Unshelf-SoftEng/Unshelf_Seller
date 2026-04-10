import 'package:unshelf_seller/core/base_viewmodel.dart';
import 'package:unshelf_seller/core/constants/status_constants.dart';
import 'package:unshelf_seller/core/interfaces/i_wallet_service.dart';
import 'package:unshelf_seller/core/service_locator.dart';
import 'package:unshelf_seller/models/transaction_model.dart';

class WalletViewModel extends BaseViewModel {
  final IWalletService _walletService;

  double _balance = 0;
  final List<Transaction> _transactions = [];

  double get balance => _balance;
  List<Transaction> get transactions => _transactions;

  WalletViewModel({IWalletService? walletService})
      : _walletService = walletService ?? locator<IWalletService>() {
    updateTransactions();
  }

  Future<void> withdrawRequest(double amount, String accountName,
      String bankName, String bankAccount) async {
    await runBusyFuture(() async {
      await _walletService.submitWithdrawalRequest(
        amount: amount,
        accountName: accountName,
        bankName: bankName,
        bankAccount: bankAccount,
      );

      _balance -= amount;
    });
  }

  // Method to update balance based on the transactions
  Future<void> updateTransactions() async {
    await runBusyFuture(() async {
      final docs = await _walletService.fetchAllTransactions();

      // Clear existing transactions
      _transactions.clear();

      double newBalance = 0.0;

      for (var doc in docs) {
        final rawDate = doc['date'];
        DateTime date;
        if (rawDate is DateTime) {
          date = rawDate;
        } else {
          // Firestore Timestamp returned as a map entry; use its toDate() if available
          date = (rawDate as dynamic).toDate() as DateTime;
        }

        if (doc['type'] == StatusConstants.withdraw) {
          double amount = (doc['amount'] as num).toDouble();

          _transactions.add(Transaction(
              type: StatusConstants.withdraw,
              amount: amount,
              date: date,
              orderId: 'XXXXXX-XXX'));
          newBalance -= amount;
        } else {
          String orderId = doc['orderId'] as String;

          if (doc['isPaid'] == true) {
            double sellerEarnings =
                (doc['sellerEarnings'] as num).toDouble();

            _transactions.add(Transaction(
                type: StatusConstants.sale,
                amount: sellerEarnings,
                date: date,
                orderId: orderId));

            newBalance += sellerEarnings;
          } else {
            double transactionFee =
                (doc['transactionFee'] as num).toDouble();
            _transactions.add(Transaction(
                type: 'Commission Fee',
                amount: transactionFee,
                date: date,
                orderId: orderId));

            newBalance -= transactionFee;
          }
        }
      }

      _balance = newBalance;
    });
  }
}
