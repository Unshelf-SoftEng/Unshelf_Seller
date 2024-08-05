import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unshelf_seller/viewmodels/wallet_viewmodel.dart';

class WalletView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WalletViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Wallet Balance'),
        ),
        body: Consumer<WalletViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (viewModel.errorMessage != null) {
              return Center(child: Text(viewModel.errorMessage!));
            } else {
              return Center(
                child: Text(
                  'Balance: \$${viewModel.balance.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 24),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
