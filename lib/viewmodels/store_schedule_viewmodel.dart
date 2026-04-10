import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unshelf_seller/core/base_viewmodel.dart';
import 'package:unshelf_seller/core/interfaces/i_store_service.dart';
import 'package:unshelf_seller/core/logger.dart';
import 'package:unshelf_seller/models/store_model.dart';

class StoreScheduleViewModel extends BaseViewModel {
  final IStoreService _storeService;
  final DateFormat _timeFormatter = DateFormat('hh:mm a');
  late Map<String, Map<String, dynamic>> _storeSchedule;

  StoreScheduleViewModel(StoreModel storeDetails,
      {required IStoreService storeService})
      : _storeService = storeService {
    AppLogger.debug('Store schedule: ${storeDetails.storeSchedule}');

    for (var entry in storeDetails.storeSchedule!.entries) {
      AppLogger.debug('Day: ${entry.key}, Value: ${entry.value}');
    }

    storeDetails.storeSchedule?.forEach((key, value) {
      // Check if 'isOpen' doesn't exist or is null
      if (value['isOpen'] == null) {
        value['isOpen'] = false;
      }

      if (value['open'] == 'Closed') {
        value['open'] = '';
      }

      if (value['close'] == 'Closed') {
        value['close'] = '';
      }
    });

    final List<String> orderedDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    _storeSchedule = Map.fromEntries(
      orderedDays.map((day) {
        // Check if the storeSchedule has data for the day, otherwise default
        var schedule = storeDetails.storeSchedule?[day] ??
            {'isOpen': false, 'open': '', 'close': ''};

        // Ensure 'isOpen' is a boolean and 'open' and 'close' are strings
        return MapEntry(
          day,
          {
            'isOpen': schedule['isOpen'],
            'open': schedule['open'],
            'close': schedule['close'],
          },
        );
      }),
    );
  }

  Map<String, Map<String, dynamic>> get storeSchedule => _storeSchedule;

  Future<void> selectTime(String day, String type, TimeOfDay pickedTime) async {
    final timeString = _timeFormatter.format(
      DateTime(2023, 1, 1, pickedTime.hour, pickedTime.minute),
    );
    _storeSchedule[day]![type] = timeString;
    notifyListeners();
  }

  Future<void> toggleDay(String day) async {
    _storeSchedule[day]!['isOpen'] = !(_storeSchedule[day]!['isOpen']);

    notifyListeners();
  }

  Future<bool> saveProfile(BuildContext context, String userId) async {
    // Perform validation
    if (!_validateSchedule()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please set valid opening and closing times for active days.')),
      );
      return false;
    }

    AppLogger.debug('Passed validation');

    try {
      await _storeService.saveStoreSchedule(userId, _storeSchedule);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    }

    return true;
  }

  /// Validation Method
  bool _validateSchedule() {
    for (var entry in _storeSchedule.entries) {
      final isOpen = entry.value['isOpen'];
      final openTime = entry.value['open']?.trim();
      final closeTime = entry.value['close']?.trim();

      if (isOpen) {
        // Ensure both times are set for open days
        if (openTime == null ||
            openTime == '' ||
            closeTime == null ||
            closeTime == '') {
          return false;
        }
      }
    }
    return true;
  }
}
