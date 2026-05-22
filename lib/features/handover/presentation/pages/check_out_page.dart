import 'package:flutter/material.dart';

import 'handover_form_page.dart';

class CheckOutPage extends StatelessWidget {
  final String bookingId;
  final int? initialBatteryLevel;
  final double? latitude;
  final double? longitude;

  const CheckOutPage({
    super.key,
    required this.bookingId,
    this.initialBatteryLevel,
    this.latitude,
    this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return HandoverFormPage(
      bookingId: bookingId,
      mode: HandoverFormMode.checkOut,
      initialBatteryLevel: initialBatteryLevel,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
