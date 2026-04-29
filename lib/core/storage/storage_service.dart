import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

/// Service for secure storage operations
class StorageService {
  final FlutterSecureStorage _storage;

  StorageService({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  /// Save access token
  Future<void> saveToken(String token) async {
    await _storage.write(key: StorageKeys.accessToken, value: token);
  }

  /// Get access token
  Future<String?> getToken() async {
    return await _storage.read(key: StorageKeys.accessToken);
  }

  /// Delete access token
  Future<void> deleteToken() async {
    await _storage.delete(key: StorageKeys.accessToken);
  }

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: StorageKeys.userId, value: userId);
  }

  /// Get user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: StorageKeys.userId);
  }

  Future<void> saveString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> getString(String key) async {
    return _storage.read(key: key);
  }

  Future<void> saveBool(String key, bool value) async {
    await _storage.write(key: key, value: value.toString());
  }

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final value = await _storage.read(key: key);
    if (value == null) return defaultValue;
    return value == 'true';
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Check if user is logged in (has token)
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
