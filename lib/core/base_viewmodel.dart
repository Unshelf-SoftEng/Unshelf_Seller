import 'package:flutter/foundation.dart';

import 'package:unshelf_seller/core/logger.dart';

abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> runBusyFuture(Future<void> Function() work) async {
    setLoading(true);
    clearError();
    try {
      await work();
    } catch (e, stackTrace) {
      setError(e.toString());
      AppLogger.error('Error in ${runtimeType.toString()}: $e', e, stackTrace);
    } finally {
      setLoading(false);
    }
  }
}
