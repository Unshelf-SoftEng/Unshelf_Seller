abstract class IWalletService {
  Future<void> submitWithdrawalRequest({
    required double amount,
    required String accountName,
    required String bankName,
    required String bankAccount,
  });
  Future<List<Map<String, dynamic>>> fetchAllTransactions();
}
