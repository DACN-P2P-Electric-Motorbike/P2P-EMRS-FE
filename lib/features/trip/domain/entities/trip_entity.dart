import 'package:equatable/equatable.dart';

enum TripStatus { notStarted, ongoing, completed, cancelled }

class TripEntity extends Equatable {
  final String id;
  final String bookingId;
  final String renterId;
  final String vehicleId;
  final TripStatus status;
  final double? startLatitude;
  final double? startLongitude;
  final String? startAddress;
  final double? endLatitude;
  final double? endLongitude;
  final String? endAddress;
  final double? distanceTraveled;
  final int? duration;
  final double? startBattery;
  final double? endBattery;
  final bool hasIssues;
  final String? issueDescription;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  /// Vehicle name populated from the nested booking→vehicle relation (history).
  final String? vehicleName;

  const TripEntity({
    required this.id,
    required this.bookingId,
    required this.renterId,
    required this.vehicleId,
    required this.status,
    this.startLatitude,
    this.startLongitude,
    this.startAddress,
    this.endLatitude,
    this.endLongitude,
    this.endAddress,
    this.distanceTraveled,
    this.duration,
    this.startBattery,
    this.endBattery,
    required this.hasIssues,
    this.issueDescription,
    this.startedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.vehicleName,
  });

  static TripStatus _statusFromString(String value) {
    switch (value.toUpperCase()) {
      case 'ONGOING':
        return TripStatus.ongoing;
      case 'COMPLETED':
        return TripStatus.completed;
      case 'CANCELLED':
        return TripStatus.cancelled;
      default:
        return TripStatus.notStarted;
    }
  }

  String get statusDisplayText {
    switch (status) {
      case TripStatus.notStarted:
        return 'Chưa bắt đầu';
      case TripStatus.ongoing:
        return 'Đang di chuyển';
      case TripStatus.completed:
        return 'Hoàn thành';
      case TripStatus.cancelled:
        return 'Đã hủy';
    }
  }

  String get formattedDistance {
    if (distanceTraveled == null) return '0 km';
    return '${distanceTraveled!.toStringAsFixed(1)} km';
  }

  String get formattedDuration {
    if (duration == null) return '0 phút';
    if (duration! >= 60) {
      final hours = duration! ~/ 60;
      final mins = duration! % 60;
      return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
    }
    return '${duration} phút';
  }

  @override
  List<Object?> get props => [
    id,
    bookingId,
    renterId,
    vehicleId,
    status,
    startLatitude,
    startLongitude,
    startAddress,
    endLatitude,
    endLongitude,
    endAddress,
    distanceTraveled,
    duration,
    startBattery,
    endBattery,
    hasIssues,
    issueDescription,
    startedAt,
    completedAt,
    createdAt,
    updatedAt,
    vehicleName,
  ];
}
