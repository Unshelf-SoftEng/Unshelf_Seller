class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppException: $message${code != null ? ' ($code)' : ''}';
}

class AuthException extends AppException {
  AuthException(super.message, {super.code, super.originalError});

  @override
  String toString() => 'AuthException: $message${code != null ? ' ($code)' : ''}';
}

class FirestoreException extends AppException {
  FirestoreException(super.message, {super.code, super.originalError});

  @override
  String toString() => 'FirestoreException: $message${code != null ? ' ($code)' : ''}';
}

class ValidationException extends AppException {
  ValidationException(super.message, {super.code, super.originalError});

  @override
  String toString() => 'ValidationException: $message${code != null ? ' ($code)' : ''}';
}
