import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/models/store_model.dart';
import 'package:unshelf_seller/models/user_model.dart';
import 'package:unshelf_seller/core/base_viewmodel.dart';
import 'package:unshelf_seller/core/logger.dart';
import 'package:unshelf_seller/core/constants/firestore_constants.dart';

class StoreViewModel extends BaseViewModel {
  StoreModel? storeDetails;
  UserProfileModel? userProfile;

  Future<void> fetchUserProfile() async {
    setLoading(true);

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setError("User is not logged in");
      setLoading(false);
      return;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection(FirestoreConstants.users)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        setError("User profile not found");
        userProfile = null;
      } else {
        userProfile = UserProfileModel.fromSnapshot(userDoc);
      }
    } catch (e) {
      setError("Error fetching user profile: ${e.toString()}");
      userProfile = null;
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchStoreDetails() async {
    setLoading(true);

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setError("User is not logged in");
      setLoading(false);
      return;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection(FirestoreConstants.users)
          .doc(user.uid)
          .get();

      DocumentSnapshot storeDoc = await FirebaseFirestore.instance
          .collection(FirestoreConstants.stores)
          .doc(user.uid)
          .get();

      if (!userDoc.exists || !storeDoc.exists) {
        storeDetails = null;
        setError("User profile or store not found");
        AppLogger.warning(errorMessage ?? '');
      } else {
        AppLogger.debug('Getting Store Details Here');
        storeDetails = StoreModel.fromSnapshot(userDoc, storeDoc);
      }
    } catch (e) {
      setError("Error fetching store details: ${e.toString()}");
      AppLogger.error(errorMessage ?? '');
    } finally {
      setLoading(false);
    }
  }

  Future<int> fetchStoreFollowers() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setError("User is not logged in");
      setLoading(false);
      return 0;
    }

    try {
      // Example path to fetch followers from the Firestore database
      QuerySnapshot followersSnapshot = await FirebaseFirestore.instance
          .collection(FirestoreConstants.stores)
          .doc(user.uid)
          .collection('followers')
          .get();

      return followersSnapshot.size;
    } catch (e) {
      setError("Error fetching store followers");
      return 0; // or throw an exception if needed
    } finally {
      setLoading(false);
    }
  }

  Future<double> fetchStoreRatings() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setError("User is not logged in");
      setLoading(false);
      return 0.0;
    }

    try {
      // Example path to fetch ratings from the Firestore database
      DocumentSnapshot ratingsSnapshot = await FirebaseFirestore.instance
          .collection(FirestoreConstants.stores)
          .doc(user.uid)
          .collection('ratings')
          .doc('average')
          .get();

      // Cast the data to a Map<String, dynamic>
      Map<String, dynamic>? data =
          ratingsSnapshot.data() as Map<String, dynamic>?;

      return data?['average'] ?? 0.0;
    } catch (e) {
      setError("Error fetching store ratings");
      return 0.0; // or throw an exception if needed
    } finally {
      setLoading(false);
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

  void clear() {
    storeDetails = null;
    clearError();
    notifyListeners();
  }
}
