import 'package:workmanager/workmanager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Example function to check expired products
Future<void> checkExpiredProducts() async {
  final now = DateTime.now();
  final productsRef = FirebaseFirestore.instance.collection('products');
  final query = productsRef
      .where('expirationDate', isLessThanOrEqualTo: now)
      .where('isListed', isEqualTo: true);
  final snapshot = await query.get();

  if (!snapshot.size.isNegative) {
    final batch = FirebaseFirestore.instance.batch();
    snapshot.docs.forEach((doc) {
      batch.update(doc.reference, {'isListed': false});
    });
    await batch.commit();
    print('Expired products unlisted.');
  }
}

void scheduleTasks() {
  Workmanager().registerPeriodicTask(
    "1",
    "checkExpiredProducts",
    frequency: Duration(hours: 1), // Adjust frequency as needed
  );
}
