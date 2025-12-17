import 'dart:async';
import 'package:fe_capstone_project/core/services/socket_service.dart';
import 'package:fe_capstone_project/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:fe_capstone_project/features/notification/presentation/bloc/notification_event.dart';
import 'package:fe_capstone_project/features/notification/presentation/bloc/notification_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fe_capstone_project/injection_container.dart';

class NotificationBadge extends StatefulWidget {
  const NotificationBadge({super.key});

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  final SocketService _socketService = sl<SocketService>();
  StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    super.initState();

    // Listen for new notifications via WebSocket
    _notificationSubscription = _socketService.notificationStream.listen((_) {
      // Reload notification count when new notification arrives
      context.read<NotificationBloc>().add(const LoadNotificationsEvent());
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        int count = 0;

        if (state is NotificationsLoaded) {
          count = state.unreadCount;
        }

        return IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_outlined),
              if (count > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      count > 99 ? '99+' : count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () {
            context.go('/notifications');
          },
        );
      },
    );
  }
}
