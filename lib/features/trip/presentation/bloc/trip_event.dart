import 'package:equatable/equatable.dart';

abstract class TripEvent extends Equatable {
  const TripEvent();

  @override
  List<Object?> get props => [];
}

class StartTripEvent extends TripEvent {
  final String bookingId;
  final double? startLatitude;
  final double? startLongitude;
  final String? startAddress;
  final double? startBattery;

  const StartTripEvent({
    required this.bookingId,
    this.startLatitude,
    this.startLongitude,
    this.startAddress,
    this.startBattery,
  });

  @override
  List<Object?> get props => [
    bookingId,
    startLatitude,
    startLongitude,
    startAddress,
    startBattery,
  ];
}

class EndTripEvent extends TripEvent {
  final String tripId;
  final double? endLatitude;
  final double? endLongitude;
  final String? endAddress;
  final double? endBattery;
  final bool hasIssues;
  final String? issueDescription;

  const EndTripEvent({
    required this.tripId,
    this.endLatitude,
    this.endLongitude,
    this.endAddress,
    this.endBattery,
    this.hasIssues = false,
    this.issueDescription,
  });

  @override
  List<Object?> get props => [
    tripId,
    endLatitude,
    endLongitude,
    endAddress,
    endBattery,
    hasIssues,
    issueDescription,
  ];
}

class LoadActiveTripEvent extends TripEvent {
  const LoadActiveTripEvent();
}

class LoadTripHistoryEvent extends TripEvent {
  const LoadTripHistoryEvent();
}

class LoadTripByIdEvent extends TripEvent {
  final String tripId;
  const LoadTripByIdEvent(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class ResetTripStateEvent extends TripEvent {
  const ResetTripStateEvent();
}
