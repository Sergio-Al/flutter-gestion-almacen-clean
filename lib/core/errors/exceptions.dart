/// Base class for all custom exceptions in the app
class AppException implements Exception {
  final String message;
  
  AppException(this.message);
  
  @override
  String toString() => message;
}

/// Exception for when a requested resource is not found
class NotFoundException extends AppException {
  NotFoundException(String message) : super(message);
}

/// Exception for local database errors
class LocalDatabaseException extends AppException {
  LocalDatabaseException(String message) : super(message);
}

/// Exception for network related errors
class NetworkException extends AppException {
  NetworkException(String message) : super(message);
}

/// Exception for authentication errors
class AuthException extends AppException {
  AuthException(String message) : super(message);
}

/// Exception for validation errors
class ValidationException extends AppException {
  ValidationException(String message) : super(message);
}
