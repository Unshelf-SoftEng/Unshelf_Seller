class Transaction {
  final String type; // "withdraw" or "sale"
  final double amount; // seller earnings or withdrawal amount
  final DateTime date;
  final String? orderId;

  Transaction({
    required this.type,
    required this.amount,
    required this.date,
    this.orderId,
  });
}
