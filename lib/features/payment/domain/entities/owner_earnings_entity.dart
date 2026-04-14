import 'package:equatable/equatable.dart';

/// Represents a single earning item from a completed booking.
class EarningsBookingItem extends Equatable {
  final String bookingId;
  final double amount;
  final double platformFee;
  final double ownerAmount;
  final String method;
  final DateTime paidAt;
  final String? vehicleName;

  const EarningsBookingItem({
    required this.bookingId,
    required this.amount,
    required this.platformFee,
    required this.ownerAmount,
    required this.method,
    required this.paidAt,
    this.vehicleName,
  });

  factory EarningsBookingItem.fromJson(Map<String, dynamic> json) {
    return EarningsBookingItem(
      bookingId: json['bookingId'] as String,
      amount: (json['amount'] as num).toDouble(),
      platformFee: (json['platformFee'] as num).toDouble(),
      ownerAmount: (json['ownerAmount'] as num).toDouble(),
      method: json['method'] as String,
      paidAt: DateTime.parse(json['paidAt'] as String),
      vehicleName: json['vehicleName'] as String?,
    );
  }

  @override
  List<Object?> get props => [bookingId, amount, platformFee, ownerAmount, method, paidAt, vehicleName];
}

/// Owner earnings summary entity.
class OwnerEarningsEntity extends Equatable {
  final double totalEarned;
  final double totalPlatformFee;
  final double netEarnings;
  final int completedBookings;
  final List<EarningsBookingItem> bookings;

  const OwnerEarningsEntity({
    required this.totalEarned,
    required this.totalPlatformFee,
    required this.netEarnings,
    required this.completedBookings,
    required this.bookings,
  });

  factory OwnerEarningsEntity.fromJson(Map<String, dynamic> json) {
    return OwnerEarningsEntity(
      totalEarned: (json['totalEarned'] as num).toDouble(),
      totalPlatformFee: (json['totalPlatformFee'] as num).toDouble(),
      netEarnings: (json['netEarnings'] as num).toDouble(),
      completedBookings: json['completedBookings'] as int,
      bookings: (json['bookings'] as List<dynamic>)
          .map((e) => EarningsBookingItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [totalEarned, totalPlatformFee, netEarnings, completedBookings, bookings];
}
