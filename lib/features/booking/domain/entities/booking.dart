import 'package:equatable/equatable.dart';

/// Booking status enum matching backend
enum BookingStatus {
  PENDING,
  CONFIRMED,
  ONGOING,
  COMPLETED,
  CANCELLED,
  REJECTED;

  static BookingStatus fromString(String value) {
    return BookingStatus.values.firstWhere(
      (e) => e.name == value.toUpperCase(),
      orElse: () => BookingStatus.PENDING,
    );
  }
}

/// Booking entity - pure Dart object without any JSON logic
class BookingEntity extends Equatable {
  final String id;
  final String renterId;
  final String ownerId;
  final String vehicleId;
  final BookingStatus status;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  final double deposit;
  final String? notes;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;

  const BookingEntity({
    required this.id,
    required this.renterId,
    required this.ownerId,
    required this.vehicleId,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.deposit,
    this.notes,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
    this.confirmedAt,
    this.cancelledAt,
  });

  /// Check if booking is pending
  bool get isPending => status == BookingStatus.PENDING;

  /// Check if booking is confirmed
  bool get isConfirmed => status == BookingStatus.CONFIRMED;

  /// Check if booking is ongoing
  bool get isOngoing => status == BookingStatus.ONGOING;

  /// Check if booking is completed
  bool get isCompleted => status == BookingStatus.COMPLETED;

  /// Check if booking is cancelled
  bool get isCancelled => status == BookingStatus.CANCELLED;

  /// Check if booking is rejected
  bool get isRejected => status == BookingStatus.REJECTED;

  /// Check if booking can be cancelled
  bool get canBeCancelled => isPending || isConfirmed;

  /// Get duration in hours
  int get durationInHours {
    return endTime.difference(startTime).inHours;
  }

  /// Get status display text
  String get statusDisplayText {
    switch (status) {
      case BookingStatus.PENDING:
        return 'Chờ xác nhận';
      case BookingStatus.CONFIRMED:
        return 'Đã xác nhận';
      case BookingStatus.ONGOING:
        return 'Đang thuê';
      case BookingStatus.COMPLETED:
        return 'Hoàn thành';
      case BookingStatus.CANCELLED:
        return 'Đã hủy';
      case BookingStatus.REJECTED:
        return 'Bị từ chối';
    }
  }

  @override
  List<Object?> get props => [
    id,
    renterId,
    ownerId,
    vehicleId,
    status,
    startTime,
    endTime,
    totalPrice,
    deposit,
    notes,
    cancellationReason,
    createdAt,
    updatedAt,
    confirmedAt,
    cancelledAt,
  ];

  BookingEntity copyWith({
    String? id,
    String? renterId,
    String? ownerId,
    String? vehicleId,
    BookingStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    double? totalPrice,
    double? deposit,
    String? notes,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? confirmedAt,
    DateTime? cancelledAt,
  }) {
    return BookingEntity(
      id: id ?? this.id,
      renterId: renterId ?? this.renterId,
      ownerId: ownerId ?? this.ownerId,
      vehicleId: vehicleId ?? this.vehicleId,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalPrice: totalPrice ?? this.totalPrice,
      deposit: deposit ?? this.deposit,
      notes: notes ?? this.notes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }
}
