import 'package:flutter/material.dart';

import 'handover_form_page.dart';

class CheckInPage extends StatelessWidget {
  final String bookingId;
  final int? initialBatteryLevel;

  const CheckInPage({
    super.key,
    required this.bookingId,
    this.initialBatteryLevel,
  });

  @override
  Widget build(BuildContext context) {
    return HandoverFormPage(
      bookingId: bookingId,
      mode: HandoverFormMode.checkIn,
      initialBatteryLevel: initialBatteryLevel,
    );
  }
}
