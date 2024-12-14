import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/components/custom_app_bar.dart';
import 'package:unshelf_seller/utils/colors.dart';
import 'package:unshelf_seller/viewmodels/wallet_viewmodel.dart';
import 'package:unshelf_seller/views/withdraw_request_view.dart';
import 'package:intl/intl.dart';

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
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'Current Balance',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.palmLeaf,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    children: [
                      const TextSpan(
                        text: '\u20B1 ', // Peso symbol
                        style: TextStyle(
                          fontFamily: 'Roboto',
                        ),
                      ),
                      TextSpan(
                        text: walletViewModel.balance.toStringAsFixed(2),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'Transaction History',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.palmLeaf,
                  ),
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
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              transaction.type,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isWithdrawal
                                    ? AppColors.watermelonRed
                                    : AppColors.palmLeaf,
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: isWithdrawal
                                      ? AppColors.watermelonRed
                                      : AppColors.palmLeaf,
                                ),
                                children: [
                                  const TextSpan(
                                    text: '\u20B1 ', // Peso symbol
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                  TextSpan(
                                    text: transaction.amount.toStringAsFixed(2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          DateFormat('MM-dd-yyyy')
                              .format(transaction.date.toLocal()),
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
            'assets/icons/withdraw.png',
            width: 24,
            height: 24,
          ),
        ));
  }
}
