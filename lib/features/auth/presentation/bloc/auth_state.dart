import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

/// Base class for auth states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no authentication action performed yet
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state - authentication in progress
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Success state - user authenticated successfully
class AuthSuccess extends AuthState {
  final UserEntity user;

  const AuthSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

/// Failure state - authentication failed
class AuthFailure extends AuthState {
  final String message;

  const AuthFailure({required this.message});

  @override
  List<Object> get props => [message];
}

/// Unauthenticated state - user is not logged in
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Authenticated state - user is logged in
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

