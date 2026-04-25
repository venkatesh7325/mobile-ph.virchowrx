class AppException implements Exception {
  final String message;
  final String? code;
  const AppException({required this.message, this.code});
  @override
  String toString() => 'AppException: $message (code: $code)';
}

class NetworkException extends AppException {
  const NetworkException({String message = 'No internet connection'})
      : super(message: message, code: 'NETWORK_ERROR');
}

class TimeoutException extends AppException {
  const TimeoutException({String message = 'Request timed out'})
      : super(message: message, code: 'TIMEOUT_ERROR');
}

class ServerException extends AppException {
  final int? statusCode;
  const ServerException({
    String message = 'Server error occurred',
    this.statusCode,
    String? code,
  }) : super(message: message, code: code ?? 'SERVER_ERROR');
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({String message = 'Unauthorized access'})
      : super(message: message, code: 'UNAUTHORIZED');
}

class NotFoundException extends AppException {
  const NotFoundException({String message = 'Resource not found'})
      : super(message: message, code: 'NOT_FOUND');
}

class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;
  const ValidationException({
    String message = 'Validation failed',
    this.fieldErrors,
  }) : super(message: message, code: 'VALIDATION_ERROR');
}

class CacheException extends AppException {
  const CacheException({String message = 'Cache error occurred'})
      : super(message: message, code: 'CACHE_ERROR');
}

class ParseException extends AppException {
  const ParseException({String message = 'Failed to parse response'})
      : super(message: message, code: 'PARSE_ERROR');
}
