import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/models/store_model.dart';

class StoreViewModel extends ChangeNotifier {
  final User? user = FirebaseAuth.instance.currentUser;
  StoreModel? storeDetails;
  bool isLoading = true;
  String? errorMessage;

  StoreViewModel() {
    fetchStoreDetails();
  }

  Future<void> fetchStoreDetails() async {
    if (user == null) {
      errorMessage = "User is not logged in";
      isLoading = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      DocumentSnapshot storeDoc = await FirebaseFirestore.instance
          .collection('stores')
          .doc(user!.uid)
          .get();

      if (!userDoc.exists || !storeDoc.exists) {
        errorMessage = "User profile or store not found";
        storeDetails = null;
      } else {
        storeDetails = StoreModel.fromSnapshot(userDoc, storeDoc);
        storeDetails!.storeFollowers =
            await fetchStoreFollowers(); // Assign followers count here
        errorMessage = null; // Clear any previous error message
      }
    } catch (e) {
      errorMessage = "Error fetching user profile: ${e.toString()}";
      storeDetails = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<int> fetchStoreFollowers() async {
    if (user == null) {
      errorMessage = "User is not logged in";
      isLoading = false;
      notifyListeners();
      return 0; // or throw an exception if needed
    }

    try {
      // Example path to fetch followers from the Firestore database
      QuerySnapshot followersSnapshot = await FirebaseFirestore.instance
          .collection('stores')
          .doc(user!.uid)
          .collection('followers')
          .get();

      return followersSnapshot.size;
    } catch (e) {
      errorMessage = "Error fetching store followers";
      return 0; // or throw an exception if needed
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<double> fetchStoreRatings() async {
    if (user == null) {
      errorMessage = "User is not logged in";
      isLoading = false;
      notifyListeners();
      return 0.0; // or throw an exception if needed
    }

    try {
      // Example path to fetch ratings from the Firestore database
      DocumentSnapshot ratingsSnapshot = await FirebaseFirestore.instance
          .collection('stores')
          .doc(user!.uid)
          .collection('ratings')
          .doc('average')
          .get();

      // Cast the data to a Map<String, dynamic>
      Map<String, dynamic>? data =
          ratingsSnapshot.data() as Map<String, dynamic>?;

      return data?['average'] ?? 0.0;
    } catch (e) {
      errorMessage = "Error fetching store ratings";
      return 0.0; // or throw an exception if needed
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String formatStoreSchedule(Map<String, Map<String, String>> schedule) {
    const List<String> daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return daysOfWeek.map((day) {
      Map<String, String> times =
          schedule[day] ?? {'open': 'Closed', 'close': 'Closed'};
      String open = times['open'] ?? 'Closed';
      String close = times['close'] ?? 'Closed';
      return open == 'Closed' && close == 'Closed'
          ? '$day: Closed'
          : '$day: $open - $close';
    }).join('\n');
  }
}
