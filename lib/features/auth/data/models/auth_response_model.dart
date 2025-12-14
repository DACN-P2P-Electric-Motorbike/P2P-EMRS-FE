import 'user_model.dart';

/// Auth response model matching backend response
/// JSON structure:
/// {
///   "user": { ... },
///   "accessToken": "eyJhbG..."
/// }
class AuthResponseModel {
  final UserModel user;
  final String accessToken;

  const AuthResponseModel({required this.user, required this.accessToken});

  /// Parse from JSON response
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'user': user.toJson(), 'accessToken': accessToken};
  }
}
