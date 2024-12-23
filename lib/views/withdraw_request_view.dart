import 'package:flutter/material.dart';
import 'package:unshelf_seller/components/custom_app_bar.dart';
import 'package:unshelf_seller/viewmodels/wallet_viewmodel.dart';
import 'package:unshelf_seller/utils/colors.dart';
import 'package:unshelf_seller/components/custom_button.dart';

class WithdrawRequestView extends StatefulWidget {
  final WalletViewModel walletViewModel;

  const WithdrawRequestView({super.key, required this.walletViewModel});

  @override
  State<WithdrawRequestView> createState() => _WithdrawRequestViewState();
}

class _WithdrawRequestViewState extends State<WithdrawRequestView> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _bankAccountController = TextEditingController();

  String _errorMessage = '';
  String? _selectedBank;

  final List<String> _phBanks = [
    'BDO',
    'BPI',
    'Metrobank',
    'LandBank',
    'Security Bank',
    'UnionBank',
    'PNB',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: 'Withdraw Request',
          onBackPressed: () {
            Navigator.pop(context);
          }),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Current Balance: ₱ ${widget.walletViewModel.balance.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Full Name Input Field
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.middleGreenYellow),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.middleGreenYellow),
                  ),
                  errorText:
                      _errorMessage.isNotEmpty && _errorMessage.contains('name')
                          ? _errorMessage
                          : null,
                ),
              ),
              const SizedBox(height: 16),
              // Bank Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Bank',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.middleGreenYellow),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.middleGreenYellow),
                  ),
                ),
                value: _selectedBank,
                items: _phBanks
                    .map((bank) => DropdownMenuItem(
                          value: bank,
                          child: Text(bank),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBank = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Bank Account Number Input Field
              TextField(
                controller: _bankAccountController,
                decoration: InputDecoration(
                  labelText: 'Bank Account Number',
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.middleGreenYellow),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.middleGreenYellow),
                  ),
                  errorText: _errorMessage.isNotEmpty &&
                          _errorMessage.contains('account')
                      ? _errorMessage
                      : null,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // Withdrawal Amount Input Field
              TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Withdrawal Amount',
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.middleGreenYellow),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.middleGreenYellow),
                  ),
                  errorText: _errorMessage.isNotEmpty &&
                          _errorMessage.contains('amount')
                      ? _errorMessage
                      : null,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // Submit Button
              CustomButton(
                onPressed: () {
                  final double? amount =
                      double.tryParse(_amountController.text);
                  final String fullName = _fullNameController.text.trim();
                  final String bankAccount = _bankAccountController.text.trim();

                  setState(() {
                    // Validate all fields
                    if (fullName.isEmpty) {
                      _errorMessage = 'Please enter your full name.';
                    } else if (_selectedBank == null) {
                      _errorMessage = 'Please select a bank.';
                    } else if (bankAccount.isEmpty) {
                      _errorMessage = 'Please enter your bank account number.';
                    } else if (amount == null || amount <= 0) {
                      _errorMessage = 'Please enter a valid amount.';
                    } else if (amount < 1000) {
                      _errorMessage = 'The minimum withdrawal amount is 1000.';
                    } else if (widget.walletViewModel.balance < amount) {
                      _errorMessage =
                          'Insufficient balance for this withdrawal.';
                    } else {
                      // Reset error message
                      _errorMessage = '';

                      // Call the withdraw request
                      widget.walletViewModel.withdrawRequest(
                          amount, fullName, _selectedBank!, bankAccount);
                      Navigator.pop(context);
                    }
                  });
                },
                text: 'Submit Request',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
