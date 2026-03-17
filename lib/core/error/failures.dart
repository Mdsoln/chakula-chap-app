import 'package:equatable/equatable.dart';

/// Base class for all domain-level failures.
/// Used with dartz Either<Failure, T> for safe error propagation.
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

// ── Network Failures ──────────────────────────────────────────────────────────

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection. Please check your network.'});
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message = 'Request timed out. Please try again.'});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message = 'Session expired. Please log in again.'})
      : super(statusCode: 401);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure({super.message = 'You do not have permission to perform this action.'})
      : super(statusCode: 403);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'The requested resource was not found.'})
      : super(statusCode: 404);
}

class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;

  const ValidationFailure({
    required super.message,
    this.fieldErrors,
  }) : super(statusCode: 422);

  @override
  List<Object?> get props => [message, statusCode, fieldErrors];
}

class LocationFailure extends Failure {
  const LocationFailure({super.message = 'Could not determine location.'});
}

// ── Local Failures ────────────────────────────────────────────────────────────

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Failed to load cached data.'});
}

class StorageFailure extends Failure {
  const StorageFailure({required super.message});
}

// ── Domain Failures ───────────────────────────────────────────────────────────

class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

class OtpFailure extends Failure {
  const OtpFailure({required super.message});
}

class PaymentFailure extends Failure {
  const PaymentFailure({required super.message, super.statusCode});
}

class OrderFailure extends Failure {
  const OrderFailure({required super.message});
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred. Please try again.',
  });
}