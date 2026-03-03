import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/trip_usecases.dart';
import 'trip_event.dart';
import 'trip_state.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  final StartTripUseCase _startTrip;
  final EndTripUseCase _endTrip;
  final GetActiveTripUseCase _getActiveTrip;
  final GetTripHistoryUseCase _getTripHistory;
  final GetTripByIdUseCase _getTripById;

  TripBloc({
    required StartTripUseCase startTrip,
    required EndTripUseCase endTrip,
    required GetActiveTripUseCase getActiveTrip,
    required GetTripHistoryUseCase getTripHistory,
    required GetTripByIdUseCase getTripById,
  }) : _startTrip = startTrip,
       _endTrip = endTrip,
       _getActiveTrip = getActiveTrip,
       _getTripHistory = getTripHistory,
       _getTripById = getTripById,
       super(const TripInitial()) {
    on<StartTripEvent>(_onStartTrip);
    on<EndTripEvent>(_onEndTrip);
    on<LoadActiveTripEvent>(_onLoadActiveTrip);
    on<LoadTripHistoryEvent>(_onLoadTripHistory);
    on<LoadTripByIdEvent>(_onLoadTripById);
    on<ResetTripStateEvent>(_onReset);
  }

  Future<void> _onStartTrip(
    StartTripEvent event,
    Emitter<TripState> emit,
  ) async {
    emit(const TripLoading());
    final result = await _startTrip(
      StartTripParams(
        bookingId: event.bookingId,
        startLatitude: event.startLatitude,
        startLongitude: event.startLongitude,
        startAddress: event.startAddress,
        startBattery: event.startBattery,
      ),
    );
    result.fold(
      (failure) => emit(TripFailure(failure.message)),
      (trip) => emit(TripStarted(trip)),
    );
  }

  Future<void> _onEndTrip(
    EndTripEvent event,
    Emitter<TripState> emit,
  ) async {
    emit(const TripLoading());
    final result = await _endTrip(
      EndTripParams(
        tripId: event.tripId,
        endLatitude: event.endLatitude,
        endLongitude: event.endLongitude,
        endAddress: event.endAddress,
        endBattery: event.endBattery,
        hasIssues: event.hasIssues,
        issueDescription: event.issueDescription,
      ),
    );
    result.fold(
      (failure) => emit(TripFailure(failure.message)),
      (trip) => emit(TripEnded(trip)),
    );
  }

  Future<void> _onLoadActiveTrip(
    LoadActiveTripEvent event,
    Emitter<TripState> emit,
  ) async {
    emit(const TripLoading());
    final result = await _getActiveTrip(const NoParams());
    result.fold(
      (failure) => emit(TripFailure(failure.message)),
      (trip) => trip != null
          ? emit(TripLoaded(trip))
          : emit(const NoActiveTrip()),
    );
  }

  Future<void> _onLoadTripHistory(
    LoadTripHistoryEvent event,
    Emitter<TripState> emit,
  ) async {
    emit(const TripLoading());
    final result = await _getTripHistory(const NoParams());
    result.fold(
      (failure) => emit(TripFailure(failure.message)),
      (trips) => emit(TripHistoryLoaded(trips)),
    );
  }

  Future<void> _onLoadTripById(
    LoadTripByIdEvent event,
    Emitter<TripState> emit,
  ) async {
    emit(const TripLoading());
    final result = await _getTripById(GetTripByIdParams(event.tripId));
    result.fold(
      (failure) => emit(TripFailure(failure.message)),
      (trip) => emit(TripLoaded(trip)),
    );
  }

  void _onReset(ResetTripStateEvent event, Emitter<TripState> emit) {
    emit(const TripInitial());
  }
}
