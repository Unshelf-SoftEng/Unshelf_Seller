import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/components/custom_app_bar.dart';
import 'package:unshelf_seller/utils/colors.dart';
import 'package:unshelf_seller/viewmodels/wallet_viewmodel.dart';
import 'package:unshelf_seller/views/withdraw_request_view.dart';
import 'package:flutter/cupertino.dart';

class BalanceOverviewView extends StatelessWidget {
  const BalanceOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final walletViewModel = Provider.of<WalletViewModel>(context);

    return Scaffold(
        appBar: CustomAppBar(
            title: 'Balance Overview',
            onBackPressed: () {
              Navigator.pop(context);
            }),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Balance',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '${walletViewModel.balance.toStringAsFixed(2)} Php',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A994E),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Transaction History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: walletViewModel.transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = walletViewModel.transactions[index];
                    bool isWithdrawal = (transaction.type == 'Withdraw' ||
                        transaction.type == 'Commission Fee');
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      child: ListTile(
                        leading: Icon(
                          isWithdrawal
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: isWithdrawal
                              ? AppColors.watermelonRed
                              : AppColors.palmLeaf,
                        ),
                        title: Text(
                          '${transaction.type} ${transaction.amount.toStringAsFixed(2)} Php',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isWithdrawal
                                ? AppColors.watermelonRed
                                : AppColors.palmLeaf,
                          ),
                        ),
                        subtitle: Text(
                          transaction.date
                              .toLocal()
                              .toString()
                              .substring(0, 16),
                          style: const TextStyle(color: Colors.grey),
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    WithdrawRequestView(walletViewModel: walletViewModel),
              ),
            );
          },
          backgroundColor: AppColors.palmLeaf,
          child: Image.asset(
            'assets/icons/withdraw_icon.png',
            width: 24,
            height: 24,
          ),
        ));
  }
}
