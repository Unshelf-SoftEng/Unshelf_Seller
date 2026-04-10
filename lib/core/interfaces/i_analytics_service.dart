import 'package:cloud_firestore/cloud_firestore.dart';

abstract class IAnalyticsService {
  Future<List<QueryDocumentSnapshot>> fetchOrders({DateTime? since});
  Future<List<QueryDocumentSnapshot>> fetchTransactions({DateTime? since});
}
