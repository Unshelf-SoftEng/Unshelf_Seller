// store_view_model.dart
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

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (!doc.exists) {
        errorMessage = "User profile not found";
      } else {
        storeDetails = StoreModel.fromSnapshot(doc);
      }
    } catch (e) {
      errorMessage = "Error fetching user profile";
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
