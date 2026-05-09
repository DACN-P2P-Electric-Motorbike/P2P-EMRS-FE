import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../platform/browser_geolocation.dart';

class LocationResult {
  final Position? position;
  final String? errorMessage;

  const LocationResult._({this.position, this.errorMessage});

  const LocationResult.success(Position position) : this._(position: position);

  const LocationResult.failure(String message) : this._(errorMessage: message);
}

/// Service for handling GPS location, permissions, and distance calculations.
class LocationService {
  /// Check and request location permission.
  /// Returns `true` if permission is granted (whileInUse or always).
  Future<bool> checkAndRequestPermission() async {
    if (!kIsWeb) {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      if (kIsWeb) {
        // On web, calling getCurrentPosition is what triggers the browser
        // prompt. geolocator_web's requestPermission can turn any failure into
        // deniedForever, hiding timeout/provider errors.
        return true;
      }

      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get the current GPS position.
  /// Returns `null` if permission is denied or location service is disabled.
  Future<Position?> getCurrentPosition() async {
    final result = await getCurrentPositionResult();
    return result.position;
  }

  Future<LocationResult> getCurrentPositionResult() async {
    final hasPermission = await checkAndRequestPermission();
    if (!hasPermission) {
      return const LocationResult.failure(
        'Quyền định vị chưa được cấp hoặc dịch vụ định vị đang tắt.',
      );
    }

    try {
      final position = await _readPosition(LocationAccuracy.high);
      return LocationResult.success(position);
    } on TimeoutException {
      try {
        final position = await _readPosition(LocationAccuracy.medium);
        return LocationResult.success(position);
      } catch (error) {
        return LocationResult.failure(_locationErrorMessage(error));
      }
    } catch (error) {
      return LocationResult.failure(_locationErrorMessage(error));
    }
  }

  Future<Position> _readPosition(LocationAccuracy accuracy) {
    if (kIsWeb) {
      return _readBrowserPosition(accuracy);
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: accuracy,
      timeLimit: const Duration(seconds: 12),
    );
  }

  Future<Position> _readBrowserPosition(LocationAccuracy accuracy) async {
    final position = await getBrowserCurrentPosition(
      enableHighAccuracy: accuracy == LocationAccuracy.high,
      timeout: const Duration(seconds: 12),
      maximumAge: const Duration(minutes: 2),
    );
    if (position != null) return position;

    return Geolocator.getCurrentPosition(
      desiredAccuracy: accuracy,
      timeLimit: const Duration(seconds: 12),
    );
  }

  String _locationErrorMessage(Object error) {
    if (error is PermissionDeniedException) {
      return 'Trình duyệt chưa cấp quyền định vị cho trang này.';
    }
    if (error is LocationServiceDisabledException) {
      return 'Dịch vụ định vị của thiết bị đang tắt.';
    }
    if (error is TimeoutException) {
      return 'Trình duyệt không trả về vị trí kịp thời. Hãy kiểm tra định vị hệ điều hành và thử lại.';
    }

    final raw = error.toString().toLowerCase();
    if (raw.contains('permission')) {
      return 'Trình duyệt chưa cấp quyền định vị cho trang này.';
    }
    if (raw.contains('network')) {
      return 'Trình duyệt không thể xác định vị trí do lỗi mạng hoặc dịch vụ vị trí.';
    }
    if (raw.contains('timeout')) {
      return 'Trình duyệt không trả về vị trí kịp thời. Hãy kiểm tra định vị hệ điều hành và thử lại.';
    }

    return kIsWeb
        ? 'Trình duyệt không lấy được vị trí. Hãy bật quyền vị trí cho localhost và kiểm tra định vị của hệ điều hành.'
        : 'Không lấy được vị trí từ thiết bị. Vui lòng bật định vị và thử lại.';
  }

  /// Calculate the distance in meters between two coordinates.
  double distanceBetween(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Stream of position updates for real-time tracking.
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}
