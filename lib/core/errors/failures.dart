// Base failure class for application errors
abstract class Failure {
  final String message;
  
  const Failure({required this.message});
}

// Database related failures
class DatabaseFailure extends Failure {
  const DatabaseFailure({required String message}) : super(message: message);
}

// Server related failures
class ServerFailure extends Failure {
  const ServerFailure({required String message}) : super(message: message);
}

// Validation related failures
class ValidationFailure extends Failure {
  const ValidationFailure({required String message}) : super(message: message);
}

// Network failures
class NetworkFailure extends Failure {
  const NetworkFailure({required String message}) : super(message: message);
}

// Cache failures
class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message: message);
}

// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure({required String message}) : super(message: message);
}

// Unexpected failures for unforeseen errors
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required String message}) : super(message: message);
}
