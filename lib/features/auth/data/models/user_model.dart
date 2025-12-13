import '../../domain/entities/user.dart';

/// User role enum matching backend
enum UserRole {
  RENTER,
  OWNER,
  ADMIN;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value.toUpperCase(),
      orElse: () => UserRole.RENTER,
    );
  }
}

/// User status enum matching backend
enum UserStatus {
  ACTIVE,
  PENDING,
  BLOCKED;

  static UserStatus fromString(String value) {
    return UserStatus.values.firstWhere(
      (e) => e.name == value.toUpperCase(),
      orElse: () => UserStatus.ACTIVE,
    );
  }
}

/// User model for API responses
/// Field names must match the JSON returned by NestJS exactly
class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String? avatarUrl;
  final List<String> roles;
  final UserStatus status;
  final double trustScore;
  final String? idCardNum;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    this.avatarUrl,
    required this.roles,
    required this.status,
    required this.trustScore,
    this.idCardNum,
    this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Parse from JSON response
  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<String> roles;

    // Check if backend returns roles array (new format)
    if (json.containsKey('roles') && json['roles'] is List) {
      roles = (json['roles'] as List).map((e) => e.toString()).toList();
    }
    // Fallback to single role (backward compatibility)
    else if (json.containsKey('role')) {
      roles = [json['role'] as String];
    }
    // Default to RENTER if no role specified
    else {
      roles = ['RENTER'];
    }
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      roles: roles,
      status: UserStatus.fromString(json['status'] as String),
      trustScore: (json['trustScore'] as num).toDouble(),
      idCardNum: json['idCardNum'] as String?,
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'roles': roles,
      'status': status.name,
      'trustScore': trustScore,
      'idCardNum': idCardNum,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert to domain entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      fullName: fullName,
      phone: phone,
      avatarUrl: avatarUrl,
      roles: roles,
      status: status.name,
      trustScore: trustScore,
      idCardNum: idCardNum,
      address: address,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
