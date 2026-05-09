// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:geolocator/geolocator.dart';

Future<Position?> getBrowserCurrentPosition({
  required bool enableHighAccuracy,
  required Duration timeout,
  Duration? maximumAge,
}) async {
  final geolocation = html.window.navigator.geolocation;
  final webPosition = await geolocation.getCurrentPosition(
    enableHighAccuracy: enableHighAccuracy,
    timeout: timeout,
    maximumAge: maximumAge,
  );
  final coords = webPosition.coords;
  if (coords == null || coords.latitude == null || coords.longitude == null) {
    return null;
  }

  final timestamp = webPosition.timestamp;
  return Position(
    latitude: coords.latitude!.toDouble(),
    longitude: coords.longitude!.toDouble(),
    timestamp: timestamp == null
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(timestamp),
    accuracy: coords.accuracy?.toDouble() ?? 0,
    altitude: coords.altitude?.toDouble() ?? 0,
    altitudeAccuracy: coords.altitudeAccuracy?.toDouble() ?? 0,
    heading: coords.heading?.toDouble() ?? 0,
    headingAccuracy: 0,
    speed: coords.speed?.toDouble() ?? 0,
    speedAccuracy: 0,
  );
}
