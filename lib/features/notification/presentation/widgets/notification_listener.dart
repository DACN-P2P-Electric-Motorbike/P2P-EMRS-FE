import 'dart:async';
import 'package:fe_capstone_project/core/localization/notification_text_localizer.dart';
import 'package:fe_capstone_project/core/services/notification_toast_service.dart';
import 'package:fe_capstone_project/core/services/socket_service.dart';
import 'package:fe_capstone_project/core/router/app_router.dart';
import 'package:fe_capstone_project/features/booking/presentation/pages/booking_detail_page.dart';
import 'package:fe_capstone_project/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:fe_capstone_project/features/notification/presentation/bloc/notification_event.dart';
import 'package:fe_capstone_project/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationListenerWidget extends StatefulWidget {
  final Widget child;

  const NotificationListenerWidget({super.key, required this.child});

  @override
  State<NotificationListenerWidget> createState() =>
      _NotificationListenerWidgetState();
}

class _NotificationListenerWidgetState
    extends State<NotificationListenerWidget> {
  final SocketService _socketService = sl<SocketService>();
  final NotificationToastService _toastService = NotificationToastService();

  StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _setupNotificationListener();
  }

  void _setupNotificationListener() {
    _notificationSubscription = _socketService.notificationStream.listen((
      data,
    ) {
      final type = data['type'] as String? ?? 'notification';
      final notificationData = data['data'] as Map<String, dynamic>?;

      if (notificationData == null) {
        return;
      }

      // Extract notification object
      final notification =
          notificationData['notification'] as Map<String, dynamic>?;
      if (notification == null) {
        return;
      }

      if (!mounted) return;

      final notificationType = notification['type'] as String? ?? type;
      final title = notification['title'] as String? ?? 'New Notification';
      final message = notification['message'] as String? ?? '';
      final recipientRole = notificationData['recipientRole'] as String?;
      final localized = NotificationTextLocalizer.localize(
        type: notificationType,
        title: title,
        message: message,
        locale: Localizations.localeOf(context),
      );

      final bookingId = notification['bookingId'] as String?;
      _toastService.showNotificationToast(
        title: localized.title,
        message: localized.message,
        type: notificationType,
        onTap: () {
          if (bookingId != null) {
            _navigateToBooking(
              bookingId,
              notificationType,
              recipientRole: recipientRole,
            );
          }
        },
      );

      // Reload notifications list
      context.read<NotificationBloc>().add(const LoadNotificationsEvent());

      // Optional: Play notification sound
      // await AudioPlayer().play(AssetSource('sounds/notification.mp3'));

      // Optional: Vibration
      // if (await Vibration.hasVibrator()) {
      //   Vibration.vibrate(duration: 200);
      // }
    });
  }

  void _navigateToBooking(
    String bookingId,
    String type, {
    String? recipientRole,
  }) {
    final isOwnerView =
        recipientRole?.toLowerCase() == 'owner' ||
        type == 'BOOKING_REQUEST' ||
        type == 'PAYOUT_UPDATED';

    // Use root navigator key to navigate from notification
    rootNavigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) =>
            BookingDetailPage(bookingId: bookingId, isOwnerView: isOwnerView),
      ),
    );
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
