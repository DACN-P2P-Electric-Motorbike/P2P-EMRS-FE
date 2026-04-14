import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the vehicle pickup location in the device's maps app or browser.
///
/// Uses Google Maps search URLs (no Maps JavaScript / embed API key required).
/// Prefers [latitude]/[longitude] when both are set; otherwise uses [address].
Future<void> openVehicleLocationInExternalMaps(
  BuildContext context, {
  required String address,
  double? latitude,
  double? longitude,
}) async {
  final Uri uri;
  if (latitude != null && longitude != null) {
    uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
  } else if (address.trim().isNotEmpty) {
    uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address.trim())}',
    );
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chưa có địa chỉ hoặc tọa độ cho vị trí này'),
        ),
      );
    }
    return;
  }

  try {
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở bản đồ trên thiết bị này')),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở bản đồ. Hãy thử lại sau.')),
      );
    }
  }
}
