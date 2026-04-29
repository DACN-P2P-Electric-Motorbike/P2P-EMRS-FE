import 'package:equatable/equatable.dart';
import '../../data/models/register_params.dart';

/// Base class for auth events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when user attempts to login
class AuthLoginStarted extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginStarted({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

/// Event triggered when user attempts to register
class AuthRegisterStarted extends AuthEvent {
  final RegisterParams registerParams;

  const AuthRegisterStarted({required this.registerParams});

  @override
  List<Object> get props => [registerParams];
}

/// Event triggered when user logs out
class AuthLogoutStarted extends AuthEvent {
  const AuthLogoutStarted();
}

/// Event triggered to check authentication status
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Event triggered to reset auth state (after error handling)
class AuthResetRequested extends AuthEvent {
  const AuthResetRequested();
}

/// Event triggered when user updates their profile
class UpdateProfileStarted extends AuthEvent {
  final String? email;
  final String? fullName;
  final String? phone;
  final String? avatarUrl;
  final String? address;
  final String? otp;

  const UpdateProfileStarted({
    this.email,
    this.fullName,
    this.phone,
    this.avatarUrl,
    this.address,
    this.otp,
  });

  @override
  List<Object?> get props => [email, fullName, phone, avatarUrl, address, otp];
}

class RequestSensitiveOtpStarted extends AuthEvent {
  final String purpose;

  const RequestSensitiveOtpStarted({required this.purpose});

  @override
  List<Object?> get props => [purpose];
}
