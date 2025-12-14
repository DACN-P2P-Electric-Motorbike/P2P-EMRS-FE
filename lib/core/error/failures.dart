import 'package:equatable/equatable.dart';

/// Base failure class
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Server failure - when API returns an error
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({required String message, this.statusCode})
    : super(message);

  @override
  List<Object> get props => [message, statusCode ?? 0];
}

/// Connection failure - when network is unavailable
class ConnectionFailure extends Failure {
  const ConnectionFailure() : super('No internet connection');
}

/// Cache failure - when local storage fails
class CacheFailure extends Failure {
  const CacheFailure() : super('Failed to access local storage');
}

/// Authentication failure - invalid credentials
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({String message = 'Invalid email or password'})
    : super(message);
}

/// Conflict failure - resource already exists
class ConflictFailure extends Failure {
  const ConflictFailure({String message = 'Resource already exists'})
    : super(message);
}

/// Validation failure - invalid input
class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;

  const ValidationFailure({String message = 'Validation failed', this.errors})
    : super(message);

  @override
  List<Object> get props => [message, errors ?? {}];
}
