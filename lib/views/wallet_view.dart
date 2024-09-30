import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/wallet_viewmodel.dart';

class WalletView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final walletViewModel = Provider.of<WalletViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet'),
        centerTitle: true,
        backgroundColor: const Color(0xFF6A994E), // Set your preferred color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Balance',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Center(
              // Center the balance text
              child: Text(
                '${walletViewModel.balance.toStringAsFixed(2)} Php',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6A994E),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Transaction History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Divider(), // Adds a separator line
            Expanded(
              child: ListView.builder(
                itemCount: walletViewModel.transactions.length,
                itemBuilder: (context, index) {
                  final transaction = walletViewModel.transactions[index];
                  bool isWithdrawal = transaction.type == 'withdraw';
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    child: ListTile(
                      leading: Icon(
                        isWithdrawal
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: isWithdrawal ? Colors.red : Colors.green,
                      ),
                      title: Text(
                        '${transaction.type.capitalize()} ${transaction.amount.toStringAsFixed(2)} Php',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isWithdrawal ? Colors.red : Colors.green,
                        ),
                      ),
                      subtitle: Text(
                        '${transaction.date.toLocal().toString().substring(0, 16)}',
                        style: TextStyle(color: Colors.grey),
                      ),
                      tileColor:
                          isWithdrawal ? Colors.red[50] : Colors.green[50],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringCapitalize on String {
  String capitalize() {
    if (this.isEmpty) {
      return this;
    }
    return '${this[0].toUpperCase()}${this.substring(1)}';
  }
}
