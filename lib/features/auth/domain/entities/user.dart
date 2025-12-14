import 'package:equatable/equatable.dart';

/// User entity - pure Dart object without any JSON logic
/// This is the domain representation of a user
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String? avatarUrl;
  final List<String> roles;
  final String status;
  final double trustScore;
  final String? idCardNum;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
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

  /// Check if user has a specific role
  bool hasRole(String role) => roles.contains(role.toUpperCase());

  /// Check if user is a renter
  bool get isRenter => hasRole('RENTER');

  /// Check if user is an owner
  bool get isOwner => hasRole('OWNER');

  /// Check if user is an admin
  bool get isAdmin => hasRole('ADMIN');

  /// Check if user is active
  bool get isActive => status == 'ACTIVE';

  /// Check if user is pending verification
  bool get isPending => status == 'PENDING';

  /// Check if user is blocked
  bool get isBlocked => status == 'BLOCKED';

  /// Get primary role (first in the list)
  String get primaryRole => roles.isNotEmpty ? roles.first : 'RENTER';

  /// Check if user has both renter and owner roles
  bool get hasMultipleRoles => roles.length > 1;

  /// Get display role name
  String get displayRole {
    if (hasMultipleRoles) {
      // If user has multiple roles, show combined
      final roleNames = roles.map((r) => _getRoleDisplayName(r)).join(' & ');
      return roleNames;
    }
    return _getRoleDisplayName(primaryRole);
  }

  /// Get individual role display name
  String _getRoleDisplayName(String role) {
    switch (role.toUpperCase()) {
      case 'RENTER':
        return 'Người thuê xe';
      case 'OWNER':
        return 'Chủ xe';
      case 'ADMIN':
        return 'Quản trị viên';
      default:
        return role;
    }
  }

  /// Get all roles as display names
  List<String> get displayRoles {
    return roles.map((r) => _getRoleDisplayName(r)).toList();
  }

  /// Get role badges for UI display
  List<String> get roleBadges {
    return roles;
  }

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    phone,
    avatarUrl,
    roles,
    status,
    trustScore,
    idCardNum,
    address,
    createdAt,
    updatedAt,
  ];

  UserEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? avatarUrl,
    List<String>? roles,
    String? status,
    double? trustScore,
    String? idCardNum,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      roles: roles ?? this.roles,
      status: status ?? this.status,
      trustScore: trustScore ?? this.trustScore,
      idCardNum: idCardNum ?? this.idCardNum,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
