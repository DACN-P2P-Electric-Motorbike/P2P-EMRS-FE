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
    final userJson = json['user'];
    final user = userJson is Map ? Map<String, dynamic>.from(userJson) : {};
    final rolesJson = user['roles'];
    final roles = rolesJson is List
        ? rolesJson.map((role) => role.toString()).toList()
        : <String>[];

    return BecomeOwnerResponseDto(
      userId: user['id']?.toString() ?? '',
      roles: roles,
      accessToken: json['accessToken']?.toString() ?? '',
      message: json['message']?.toString() ?? 'Đăng ký chủ xe thành công',
    );
  }

  @override
  List<Object?> get props => [userId, roles, accessToken, message];
}
