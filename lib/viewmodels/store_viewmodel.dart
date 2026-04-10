import 'package:unshelf_seller/core/base_viewmodel.dart';
import 'package:unshelf_seller/core/interfaces/i_store_service.dart';
import 'package:unshelf_seller/core/logger.dart';
import 'package:unshelf_seller/models/store_model.dart';
import 'package:unshelf_seller/models/user_model.dart';

class StoreViewModel extends BaseViewModel {
  final IStoreService _storeService;

  StoreViewModel({required IStoreService storeService})
      : _storeService = storeService;

  StoreModel? storeDetails;
  UserProfileModel? userProfile;

  Future<void> fetchUserProfile() async {
    await runBusyFuture(() async {
      userProfile = await _storeService.fetchUserProfile();
      if (userProfile == null) {
        setError('User profile not found');
      }
    });
  }

  Future<void> fetchStoreDetails() async {
    await runBusyFuture(() async {
      storeDetails = await _storeService.fetchStoreDetails();
      if (storeDetails == null) {
        AppLogger.warning('User profile or store not found');
        setError('User profile or store not found');
      } else {
        AppLogger.debug('Getting Store Details Here');
      }
    });
  }

  Future<int> fetchStoreFollowers() async {
    try {
      return await _storeService.fetchStoreFollowers();
    } catch (e) {
      setError('Error fetching store followers');
      return 0;
    }
  }

  Future<double> fetchStoreRatings() async {
    try {
      return await _storeService.fetchStoreRatings();
    } catch (e) {
      setError('Error fetching store ratings');
      return 0.0;
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
