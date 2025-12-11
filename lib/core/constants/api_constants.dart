/// API configuration constants
class ApiConstants {
  ApiConstants._();

  /// Base URL for the API
  /// Use 'http://10.0.2.2:3000' for Android emulator
  /// Use 'http://localhost:3000' for iOS simulator or web
  static const String baseUrl = 'http://localhost:3000';

  /// Connection timeout in milliseconds
  static const int connectTimeout = 30000;

  /// Receive timeout in milliseconds
  static const int receiveTimeout = 30000;

  /// Auth endpoints
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authProfile = '/auth/profile';

  /// Vehicle endpoints
  static const String vehicles = '/vehicles';
  static const String myVehicles = '/vehicles/my-vehicles';
  static const String availableVehicles = '/vehicles/available';
  static String vehicleById(String id) => '/vehicles/$id';

  /// Upload endpoints
  static const String uploadVehicleImage = '/upload/vehicle-image';
  static const String uploadVehicleImages = '/upload/vehicle-images';
  static const String uploadLicense = '/upload/license';
}

/// Storage keys
class StorageKeys {
  StorageKeys._();

  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
}

