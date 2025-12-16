import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/notification.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../widgets/notification_card.dart';
import '../../../booking/presentation/pages/booking_detail_page.dart';

/// Notifications Page
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<NotificationBloc>()..add(const LoadNotificationsEvent()),
      child: const _NotificationsContent(),
    );
  }
}

class _NotificationsContent extends StatefulWidget {
  const _NotificationsContent();

  @override
  State<_NotificationsContent> createState() => _NotificationsContentState();
}

class _NotificationsContentState extends State<_NotificationsContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Thông báo',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          // Mark all as read button
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationsLoaded && state.hasUnread) {
                return IconButton(
                  icon: const Icon(Icons.done_all),
                  tooltip: 'Đánh dấu tất cả đã đọc',
                  onPressed: () {
                    context.read<NotificationBloc>().add(
                      const MarkAllAsReadEvent(),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationBloc>().add(
                  const LoadNotificationsEvent(),
                );
              },
              child: _buildNotificationsList(state.notifications),
            );
          }

          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationEntity> notifications) {
    // Group notifications by date
    final grouped = <String, List<NotificationEntity>>{};
    for (final notif in notifications) {
      final dateKey = _getDateKey(notif.createdAt);
      grouped.putIfAbsent(dateKey, () => []).add(notif);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final dateKey = grouped.keys.elementAt(index);
        final items = grouped[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _getDateLabel(dateKey),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            // Notifications for this date
            ...items.map(
              (notif) => NotificationCard(
                notification: notif,
                onTap: () => _handleNotificationTap(context, notif),
                onMarkRead: notif.isUnread
                    ? () => _markAsRead(context, notif.id)
                    : null,
                onDelete: () => _deleteNotification(context, notif.id),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_outlined,
            size: 80,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'Không có thông báo',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bạn đã cập nhật tất cả!',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  String _getDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _getDateLabel(String dateKey) {
    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notifDate = DateTime(date.year, date.month, date.day);

    if (notifDate == today) {
      return 'Hôm nay';
    } else if (notifDate == yesterday) {
      return 'Hôm qua';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationEntity notification,
  ) {
    // Mark as read
    if (notification.isUnread) {
      context.read<NotificationBloc>().add(MarkAsReadEvent([notification.id]));
    }

    // Navigate to booking detail if it's a booking notification
    if (notification.bookingId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookingDetailPage(bookingId: notification.bookingId!),
        ),
      );
    }
  }

  void _markAsRead(BuildContext context, String notificationId) {
    context.read<NotificationBloc>().add(MarkAsReadEvent([notificationId]));
  }

  void _deleteNotification(BuildContext context, String notificationId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Xóa thông báo',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: const Text('Bạn có chắc chắn muốn xóa thông báo này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<NotificationBloc>().add(
                DeleteNotificationEvent(notificationId),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
