import 'package:equatable/equatable.dart';
import '../../domain/entities/trip_entity.dart';

abstract class TripState extends Equatable {
  const TripState();

  @override
  List<Object?> get props => [];
}

class TripInitial extends TripState {
  const TripInitial();
}

class TripLoading extends TripState {
  const TripLoading();
}

class TripLoaded extends TripState {
  final TripEntity trip;
  const TripLoaded(this.trip);

  @override
  List<Object?> get props => [trip];
}

class TripHistoryLoaded extends TripState {
  final List<TripEntity> trips;
  const TripHistoryLoaded(this.trips);

  @override
  List<Object?> get props => [trips];
}

class NoActiveTrip extends TripState {
  const NoActiveTrip();
}

class TripStarted extends TripState {
  final TripEntity trip;
  const TripStarted(this.trip);

  @override
  List<Object?> get props => [trip];
}

class TripEnded extends TripState {
  final TripEntity trip;
  const TripEnded(this.trip);

  @override
  List<Object?> get props => [trip];
}

class TripFailure extends TripState {
  final String message;
  const TripFailure(this.message);

  @override
  List<Object?> get props => [message];
}
