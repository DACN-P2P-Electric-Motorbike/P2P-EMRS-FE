import '../../domain/entities/booking.dart';

/// Booking model for API responses
/// Field names must match the JSON returned by NestJS exactly
class BookingModel {
  final String id;
  final String renterId;
  final String ownerId;
  final String vehicleId;
  final String status;
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

  const BookingModel({
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

  /// Parse from JSON response
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      renterId: json['renterId'] as String,
      ownerId: json['ownerId'] as String,
      vehicleId: json['vehicleId'] as String,
      status: json['status'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      deposit: (json['deposit'] as num).toDouble(),
      notes: json['notes'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'] as String)
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'renterId': renterId,
      'ownerId': ownerId,
      'vehicleId': vehicleId,
      'status': status,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'totalPrice': totalPrice,
      'deposit': deposit,
      'notes': notes,
      'cancellationReason': cancellationReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'confirmedAt': confirmedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
    };
  }

  /// Convert to domain entity
  BookingEntity toEntity() {
    return BookingEntity(
      id: id,
      renterId: renterId,
      ownerId: ownerId,
      vehicleId: vehicleId,
      status: BookingStatus.fromString(status),
      startTime: startTime,
      endTime: endTime,
      totalPrice: totalPrice,
      deposit: deposit,
      notes: notes,
      cancellationReason: cancellationReason,
      createdAt: createdAt,
      updatedAt: updatedAt,
      confirmedAt: confirmedAt,
      cancelledAt: cancelledAt,
    );
  }
}
