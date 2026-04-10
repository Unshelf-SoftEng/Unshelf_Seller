import 'package:unshelf_seller/models/store_model.dart';
import 'package:unshelf_seller/models/user_model.dart';

abstract class IStoreService {
  Future<UserProfileModel?> fetchUserProfile();
  Future<StoreModel?> fetchStoreDetails();
  Future<int> fetchStoreFollowers();
  Future<double> fetchStoreRatings();
  Future<void> updateStoreProfile(Map<String, dynamic> fields);
  Future<void> saveStoreLocation(double latitude, double longitude);
  Future<void> saveStoreSchedule(
      String userId, Map<String, Map<String, dynamic>> schedule);
}
