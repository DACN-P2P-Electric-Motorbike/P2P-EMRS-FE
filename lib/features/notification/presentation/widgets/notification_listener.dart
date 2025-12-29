import 'dart:async';
import 'package:fe_capstone_project/core/services/notification_toast_service.dart';
import 'package:fe_capstone_project/core/services/socket_service.dart';
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

      final title = notification['title'] as String? ?? 'New Notification';
      final message = notification['message'] as String? ?? '';

      // ✅ Extract bookingId from notificatHandler: "onTap"ion object
      final bookingId = notification['bookingId'] as String?;
      // Show toast
      _toastService.showNotificationToast(
        title: title,
        message: message,
        type: type,
        onTap: () {
          if (bookingId != null) {
            _navigateToBooking(bookingId, type);
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

  void _navigateToBooking(String bookingId, String type) {
    // Determine if owner view based on notification type
    final isOwnerView = type == 'BOOKING_REQUEST';

    Navigator.push(
      context,
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
