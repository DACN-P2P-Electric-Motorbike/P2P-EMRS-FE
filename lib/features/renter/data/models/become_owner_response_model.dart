import 'package:equatable/equatable.dart';

/// Response DTO for become owner API
class BecomeOwnerResponseDto extends Equatable {
  final String userId;
  final List<String> roles;
  final String accessToken;
  final String message;

  const BecomeOwnerResponseDto({
    required this.userId,
    required this.roles,
    required this.accessToken,
    required this.message,
  });

  factory BecomeOwnerResponseDto.fromJson(Map<String, dynamic> json) {
    return BecomeOwnerResponseDto(
      userId: json['user']['id'],
      roles: List<String>.from(json['user']['roles']),
      accessToken: json['accessToken'],
      message: json['message'],
    );
  }

  @override
  List<Object?> get props => [userId, roles, accessToken, message];
}
