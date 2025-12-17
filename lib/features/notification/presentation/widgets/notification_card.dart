import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/notification.dart';

/// Notification Card Widget
class NotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;
  final VoidCallback? onMarkRead;
  final VoidCallback? onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    this.onMarkRead,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: notification.isUnread
            ? AppColors.primary.withOpacity(0.03)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: notification.isUnread
            ? Border.all(color: AppColors.primary.withOpacity(0.1), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getIconColor().withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_getIcon(), color: _getIconColor(), size: 24),
                ),

                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: notification.isUnread
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (notification.isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Message
                      Text(
                        notification.message,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Time
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getTimeAgo(notification.createdAt),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                          if (notification.bookingId != null) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.bookmark,
                              size: 12,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Booking',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'read' && onMarkRead != null) {
                      onMarkRead!();
                    } else if (value == 'delete' && onDelete != null) {
                      onDelete!();
                    }
                  },
                  itemBuilder: (context) => [
                    if (notification.isUnread && onMarkRead != null)
                      PopupMenuItem(
                        value: 'read',
                        child: Row(
                          children: [
                            const Icon(Icons.done, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Đánh dấu đã đọc',
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete,
                              size: 20,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Xóa',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (notification.type) {
      case NotificationType.BOOKING_REQUEST:
        return Icons.pending_actions;
      case NotificationType.BOOKING_CONFIRMED:
        return Icons.check_circle;
      case NotificationType.BOOKING_REJECTED:
        return Icons.cancel;
      case NotificationType.BOOKING_CANCELLED:
        return Icons.event_busy;
      case NotificationType.TRIP_STARTED:
        return Icons.play_circle;
      case NotificationType.TRIP_COMPLETED:
        return Icons.task_alt;
      case NotificationType.PAYMENT_SUCCESS:
        return Icons.payments;
      case NotificationType.PAYMENT_FAILED:
        return Icons.error;
      case NotificationType.SYSTEM_ALERT:
        return Icons.notifications;
    }
  }

  Color _getIconColor() {
    switch (notification.type) {
      case NotificationType.BOOKING_REQUEST:
        return AppColors.warning;
      case NotificationType.BOOKING_CONFIRMED:
      case NotificationType.TRIP_COMPLETED:
      case NotificationType.PAYMENT_SUCCESS:
        return AppColors.success;
      case NotificationType.BOOKING_REJECTED:
      case NotificationType.BOOKING_CANCELLED:
      case NotificationType.PAYMENT_FAILED:
        return AppColors.error;
      case NotificationType.TRIP_STARTED:
        return AppColors.info;
      case NotificationType.SYSTEM_ALERT:
        return AppColors.primary;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }
}
