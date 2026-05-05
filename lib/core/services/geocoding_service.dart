import 'package:dio/dio.dart';
// import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Geocoding service backed by OpenStreetMap Nominatim.
/// No API key required. Works on all platforms (web + native) via HTTP.
class GeocodingService {
  final Dio _dio;

  GeocodingService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://nominatim.openstreetmap.org',
              headers: {
                // Nominatim requires a descriptive User-Agent
                'User-Agent': 'DreamRide/1.0 (flutter; contact@dreamride.vn)',
                'Accept-Language': 'vi,en',
              },
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
            ),
          );

  /// Convert an address string to [LatLng].
  /// Returns null if not found or on error.
  Future<LatLng?> geocodeAddress(String address) async {
    if (address.trim().isEmpty) return null;
    try {
      final response = await _dio.get<List<dynamic>>(
        '/search',
        queryParameters: {
          'q': address,
          'format': 'json',
          'limit': 1,
          'addressdetails': 0,
        },
      );
      final data = response.data;
      if (data == null || data.isEmpty) return null;
      final first = data.first as Map<String, dynamic>;
      final lat = double.tryParse(first['lat'] as String? ?? '');
      final lon = double.tryParse(first['lon'] as String? ?? '');
      if (lat == null || lon == null) return null;
      return LatLng(lat, lon);
    } catch (_) {
      return null;
    }
  }

  /// Convert [LatLng] to a human-readable address string.
  /// Returns null on error.
  Future<String?> reverseGeocode(double lat, double lng) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/reverse',
        queryParameters: {
          'lat': lat,
          'lon': lng,
          'format': 'json',
          'zoom': 17,
          'addressdetails': 0,
        },
      );
      final data = response.data;
      if (data == null) return null;
      return data['display_name'] as String?;
    } catch (_) {
      return null;
    }
  }
}

/// Result returned by [LocationPickerPage].
class LocationPickerResult {
  final double latitude;
  final double longitude;
  final String address;

  const LocationPickerResult({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}
