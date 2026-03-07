/// Exceptions are thrown in the data layer and caught/mapped to Failures
/// in repository implementations — they never reach the domain layer.
library;

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ServerException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'No internet connection.'});

  @override
  String toString() => 'NetworkException: $message';
}

class TimeoutException implements Exception {
  final String message;
  const TimeoutException({this.message = 'Connection timed out.'});
}

class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException({this.message = 'Unauthorized access.'});
}

class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});
}

class StorageException implements Exception {
  final String message;
  const StorageException({required this.message});
}

class ValidationException implements Exception {
  final String message;
  final Map<String, List<String>>? fieldErrors;

  const ValidationException({required this.message, this.fieldErrors});
}