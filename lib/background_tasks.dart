import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> checkExpiredProducts() async {
  try {
    print('Checking for expired products...');

    // Get the current time
    final now = DateTime.now();

    // Reference to the 'products' collection
    final productsRef = FirebaseFirestore.instance.collection('products');

    // Query to find expired products that are currently listed
    final query = productsRef
        .where('expirationDate', isLessThanOrEqualTo: now)
        .where('isListed', isEqualTo: true);

    // Fetch the query snapshot
    final snapshot = await query.get();

    // Check if there are documents returned
    if (snapshot.docs.isEmpty) {
      print('No expired products found.');
      return;
    }

    // Start a batch operation to update documents
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      // Update the 'isListed' field to false for expired products
      batch.update(doc.reference, {'isListed': false});
    }

    // Commit the batch
    await batch.commit();
    print('Expired products unlisted.');
  } catch (e) {
    // Handle errors and print error messages
    print('Error checking or updating expired products: $e');
  }
}
