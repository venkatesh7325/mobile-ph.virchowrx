import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

class NetworkFailure extends Failure {
  const NetworkFailure({String message = 'No internet connection'})
      : super(message: message, code: 'NETWORK_ERROR');
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure({
    String message = 'Server error occurred',
    this.statusCode,
  }) : super(message: message, code: 'SERVER_ERROR');

  @override
  List<Object?> get props => [message, code, statusCode];
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({String message = 'Request timed out'})
      : super(message: message, code: 'TIMEOUT_ERROR');
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({String message = 'Session expired. Please login again.'})
      : super(message: message, code: 'UNAUTHORIZED');
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({String message = 'Resource not found'})
      : super(message: message, code: 'NOT_FOUND');
}

class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;
  const ValidationFailure({
    String message = 'Validation failed',
    this.fieldErrors,
  }) : super(message: message, code: 'VALIDATION_ERROR');

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({String message = 'An unexpected error occurred'})
      : super(message: message, code: 'UNEXPECTED_ERROR');
}
