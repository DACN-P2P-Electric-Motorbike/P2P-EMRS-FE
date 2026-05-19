import 'package:flutter/widgets.dart';

class LocalizedNotificationText {
  final String title;
  final String message;

  const LocalizedNotificationText({required this.title, required this.message});
}

class NotificationTextLocalizer {
  const NotificationTextLocalizer._();

  static LocalizedNotificationText localize({
    required String type,
    required String title,
    required String message,
    required Locale locale,
  }) {
    final languageCode = locale.languageCode == 'en' ? 'en' : 'vi';
    final normalizedType = type.toUpperCase().replaceAll('-', '_');

    return languageCode == 'en'
        ? _english(normalizedType, title, message)
        : _vietnamese(normalizedType, title, message);
  }

  static LocalizedNotificationText _vietnamese(
    String type,
    String title,
    String message,
  ) {
    final reason = _afterAny(message, const ['Reason:', 'Lý do:']);
    final amount = _amount(message);
    final distance = _distance(message);
    final duration = _duration(message);
    final isPaymentReceived = _containsAny(title, const [
      'received',
      'đã nhận',
      'nhận thanh toán',
    ]);
    final isOwnerTripComplete = _containsAny(message, const [
      'người thuê',
      'returned vehicle',
      'trả xe',
    ]);

    switch (type) {
      case 'BOOKING_REQUEST':
        return const LocalizedNotificationText(
          title: 'Yêu cầu đặt xe mới',
          message: 'Bạn có yêu cầu đặt xe mới cho xe của mình.',
        );
      case 'BOOKING_CONFIRMED':
        return const LocalizedNotificationText(
          title: 'Đặt xe đã được xác nhận',
          message: 'Yêu cầu thuê xe của bạn đã được chủ xe chấp nhận.',
        );
      case 'BOOKING_REJECTED':
        return LocalizedNotificationText(
          title: 'Đặt xe bị từ chối',
          message: reason == null || reason.isEmpty
              ? 'Yêu cầu thuê xe của bạn đã bị từ chối.'
              : 'Yêu cầu thuê xe của bạn đã bị từ chối. Lý do: $reason',
        );
      case 'BOOKING_CANCELLED':
        return LocalizedNotificationText(
          title: 'Đặt xe đã bị hủy',
          message: reason == null || reason.isEmpty
              ? 'Lượt đặt xe đã được hủy.'
              : 'Lượt đặt xe đã được hủy. Lý do: $reason',
        );
      case 'TRIP_STARTED':
        return const LocalizedNotificationText(
          title: 'Chuyến đi đã bắt đầu',
          message: 'Người thuê đã bắt đầu chuyến đi với xe của bạn.',
        );
      case 'TRIP_COMPLETED':
        if (isOwnerTripComplete) {
          return LocalizedNotificationText(
            title: 'Chuyến đi đã hoàn thành',
            message: _joinMetricMessage(
              'Người thuê đã trả xe.',
              distance: distance,
              duration: duration,
              locale: 'vi',
            ),
          );
        }
        return LocalizedNotificationText(
          title: 'Chuyến đi hoàn tất',
          message: distance == null
              ? 'Chuyến đi đã được ghi nhận. Cảm ơn bạn đã sử dụng DreamRide!'
              : 'Chuyến đi đã được ghi nhận. Quãng đường: $distance km. Cảm ơn bạn đã sử dụng DreamRide!',
        );
      case 'PAYMENT_SUCCESS':
        if (isPaymentReceived) {
          return LocalizedNotificationText(
            title: 'Đã nhận thanh toán',
            message: amount == null
                ? 'Bạn vừa nhận được thanh toán từ chuyến thuê xe.'
                : 'Bạn vừa nhận được $amount VND từ chuyến thuê xe.',
          );
        }
        return LocalizedNotificationText(
          title: 'Thanh toán thành công',
          message: amount == null
              ? 'Thanh toán đã được xác nhận. Chuyến đi của bạn đã sẵn sàng!'
              : 'Thanh toán $amount VND đã được xác nhận. Chuyến đi của bạn đã sẵn sàng!',
        );
      case 'PAYMENT_FAILED':
        return const LocalizedNotificationText(
          title: 'Thanh toán thất bại',
          message: 'Giao dịch thanh toán không thành công. Vui lòng thử lại.',
        );
      default:
        return LocalizedNotificationText(
          title: title.isEmpty ? 'Thông báo' : title,
          message: message,
        );
    }
  }

  static LocalizedNotificationText _english(
    String type,
    String title,
    String message,
  ) {
    final reason = _afterAny(message, const ['Reason:', 'Lý do:']);
    final amount = _amount(message);
    final distance = _distance(message);
    final duration = _duration(message);
    final isPaymentReceived = _containsAny(title, const [
      'received',
      'đã nhận',
      'nhận thanh toán',
    ]);
    final isOwnerTripComplete = _containsAny(message, const [
      'người thuê',
      'returned vehicle',
      'trả xe',
    ]);

    switch (type) {
      case 'BOOKING_REQUEST':
        return const LocalizedNotificationText(
          title: 'New booking request',
          message: 'You have a new booking request for your vehicle.',
        );
      case 'BOOKING_CONFIRMED':
        return const LocalizedNotificationText(
          title: 'Booking confirmed',
          message: 'Your booking request has been approved.',
        );
      case 'BOOKING_REJECTED':
        return LocalizedNotificationText(
          title: 'Booking rejected',
          message: reason == null || reason.isEmpty
              ? 'Your booking request was rejected.'
              : 'Your booking request was rejected. Reason: $reason',
        );
      case 'BOOKING_CANCELLED':
        return LocalizedNotificationText(
          title: 'Booking cancelled',
          message: reason == null || reason.isEmpty
              ? 'The booking has been cancelled.'
              : 'The booking has been cancelled. Reason: $reason',
        );
      case 'TRIP_STARTED':
        return const LocalizedNotificationText(
          title: 'Trip started',
          message: 'The renter has started the trip with your vehicle.',
        );
      case 'TRIP_COMPLETED':
        if (isOwnerTripComplete) {
          return LocalizedNotificationText(
            title: 'Trip completed',
            message: _joinMetricMessage(
              'The renter has returned the vehicle.',
              distance: distance,
              duration: duration,
              locale: 'en',
            ),
          );
        }
        return LocalizedNotificationText(
          title: 'Trip completed',
          message: distance == null
              ? 'Your trip has been recorded. Thank you for using DreamRide!'
              : 'Your trip has been recorded. Distance: $distance km. Thank you for using DreamRide!',
        );
      case 'PAYMENT_SUCCESS':
        if (isPaymentReceived) {
          return LocalizedNotificationText(
            title: 'Payment received',
            message: amount == null
                ? 'You received a payment from a rental trip.'
                : 'You received $amount VND from a rental trip.',
          );
        }
        return LocalizedNotificationText(
          title: 'Payment successful',
          message: amount == null
              ? 'Your payment has been confirmed. Your trip is ready!'
              : 'Your payment of $amount VND has been confirmed. Your trip is ready!',
        );
      case 'PAYMENT_FAILED':
        return const LocalizedNotificationText(
          title: 'Payment failed',
          message: 'The payment was not successful. Please try again.',
        );
      default:
        return LocalizedNotificationText(
          title: title.isEmpty ? 'Notification' : title,
          message: message,
        );
    }
  }

  static String _joinMetricMessage(
    String prefix, {
    required String? distance,
    required String? duration,
    required String locale,
  }) {
    final parts = <String>[prefix];
    if (distance != null) {
      parts.add(
        locale == 'en'
            ? 'Distance: $distance km.'
            : 'Quãng đường: $distance km.',
      );
    }
    if (duration != null) {
      parts.add(
        locale == 'en'
            ? 'Duration: $duration minutes.'
            : 'Thời gian: $duration phút.',
      );
    }
    return parts.join(' ');
  }

  static bool _containsAny(String value, List<String> needles) {
    final lower = value.toLowerCase();
    return needles.any((needle) => lower.contains(needle.toLowerCase()));
  }

  static String? _afterAny(String value, List<String> markers) {
    for (final marker in markers) {
      final index = value.toLowerCase().indexOf(marker.toLowerCase());
      if (index >= 0) {
        return value.substring(index + marker.length).trim();
      }
    }
    return null;
  }

  static String? _amount(String value) {
    final match = RegExp(
      r'([0-9][0-9.,]*)\s*VND',
      caseSensitive: false,
    ).firstMatch(value);
    return match?.group(1);
  }

  static String? _distance(String value) {
    final match = RegExp(
      r'([0-9]+(?:[,.][0-9]+)?)\s*km',
      caseSensitive: false,
    ).firstMatch(value);
    return match?.group(1);
  }

  static String? _duration(String value) {
    final match = RegExp(
      r'([0-9]+)\s*(?:phút|minute|minutes|min)',
      caseSensitive: false,
    ).firstMatch(value);
    return match?.group(1);
  }
}
