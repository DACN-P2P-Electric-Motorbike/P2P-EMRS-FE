import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/cache/hive_cache_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/booking.dart';
import '../../domain/usecases/booking_usecases.dart';
import '../../domain/usecases/create_booking_usecase.dart';
import 'booking_event.dart';
import 'booking_state.dart';

/// Booking BLoC - handles booking state management
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final CreateBookingUseCase _createBookingUseCase;
  final CreateBookingLockUseCase _createBookingLockUseCase;
  final GetRenterBookingsUseCase _getRenterBookingsUseCase;
  final GetOwnerBookingsUseCase _getOwnerBookingsUseCase;
  final GetPendingBookingsUseCase _getPendingBookingsUseCase;
  final GetBookingByIdUseCase _getBookingByIdUseCase;
  final CancelBookingUseCase _cancelBookingUseCase;
  final ApproveBookingUseCase _approveBookingUseCase;
  final RejectBookingUseCase _rejectBookingUseCase;
  final HiveCacheService _cache;
  late final StreamSubscription<String> _cacheSubscription;
  String? _activeCacheKey;
  BookingStatus? _activeStatus;
  bool _activeOwnerList = false;
  bool _activePendingList = false;
  String? _activeBookingId;

  BookingBloc({
    required CreateBookingUseCase createBookingUseCase,
    required CreateBookingLockUseCase createBookingLockUseCase,
    required GetRenterBookingsUseCase getRenterBookingsUseCase,
    required GetOwnerBookingsUseCase getOwnerBookingsUseCase,
    required GetPendingBookingsUseCase getPendingBookingsUseCase,
    required GetBookingByIdUseCase getBookingByIdUseCase,
    required CancelBookingUseCase cancelBookingUseCase,
    required ApproveBookingUseCase approveBookingUseCase,
    required RejectBookingUseCase rejectBookingUseCase,
    required HiveCacheService cache,
  }) : _createBookingUseCase = createBookingUseCase,
       _createBookingLockUseCase = createBookingLockUseCase,
       _getRenterBookingsUseCase = getRenterBookingsUseCase,
       _getOwnerBookingsUseCase = getOwnerBookingsUseCase,
       _getPendingBookingsUseCase = getPendingBookingsUseCase,
       _getBookingByIdUseCase = getBookingByIdUseCase,
       _cancelBookingUseCase = cancelBookingUseCase,
       _approveBookingUseCase = approveBookingUseCase,
       _rejectBookingUseCase = rejectBookingUseCase,
       _cache = cache,
       super(const BookingInitial()) {
    _cacheSubscription = _cache.changes.listen(_onCacheChanged);
    on<CreateBookingEvent>(_onCreateBooking);
    on<CreateBookingLockEvent>(_onCreateBookingLock);
    on<LoadRenterBookingsEvent>(_onLoadRenterBookings);
    on<LoadOwnerBookingsEvent>(_onLoadOwnerBookings);
    on<LoadPendingBookingsEvent>(_onLoadPendingBookings);
    on<LoadBookingByIdEvent>(_onLoadBookingById);
    on<CancelBookingEvent>(_onCancelBooking);
    on<ApproveBookingEvent>(_onApproveBooking);
    on<RejectBookingEvent>(_onRejectBooking);
    on<ResetBookingStateEvent>(_onResetState);
  }

  Future<void> _onCreateBooking(
    CreateBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());

    final params = CreateBookingParams(
      vehicleId: event.vehicleId,
      startTime: event.startTime,
      endTime: event.endTime,
      notes: event.notes,
      protectionPlan: event.protectionPlan,
      prepaidCharging: event.prepaidCharging,
      roadsideSupport: event.roadsideSupport,
    );

    final result = await _createBookingUseCase(params);

    result.fold(
      (failure) => emit(BookingFailure(failure.message)),
      (booking) => emit(BookingCreated(booking)),
    );
  }

  Future<void> _onCreateBookingLock(
    CreateBookingLockEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());

    final result = await _createBookingLockUseCase(
      CreateBookingLockParams(
        vehicleId: event.vehicleId,
        startTime: event.startTime,
        endTime: event.endTime,
      ),
    );

    result.fold(
      (failure) => emit(BookingFailure(failure.message)),
      (lock) => emit(BookingLockCreated(lock)),
    );
  }

  Future<void> _onLoadRenterBookings(
    LoadRenterBookingsEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());

    final params = GetRenterBookingsParams(status: event.status);
    final result = await _getRenterBookingsUseCase(params);

    result.fold((failure) => emit(BookingFailure(failure.message)), (bookings) {
      _rememberListKey(owner: false, status: event.status);
      emit(BookingsLoaded(bookings));
    });
  }

  Future<void> _onLoadOwnerBookings(
    LoadOwnerBookingsEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());

    final params = GetOwnerBookingsParams(status: event.status);
    final result = await _getOwnerBookingsUseCase(params);

    result.fold((failure) => emit(BookingFailure(failure.message)), (bookings) {
      _rememberListKey(owner: true, status: event.status);
      emit(BookingsLoaded(bookings));
    });
  }

  Future<void> _onLoadPendingBookings(
    LoadPendingBookingsEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());

    final result = await _getPendingBookingsUseCase(const NoParams());

    result.fold((failure) => emit(BookingFailure(failure.message)), (bookings) {
      _activeCacheKey = 'bookings.owner.pending';
      _activeOwnerList = true;
      _activePendingList = true;
      _activeStatus = null;
      _activeBookingId = null;
      emit(BookingsLoaded(bookings));
    });
  }

  Future<void> _onLoadBookingById(
    LoadBookingByIdEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());

    final params = GetBookingByIdParams(event.bookingId);
    final result = await _getBookingByIdUseCase(params);

    result.fold((failure) => emit(BookingFailure(failure.message)), (booking) {
      _activeCacheKey = 'bookings.detail:${event.bookingId}';
      _activeBookingId = event.bookingId;
      _activeOwnerList = false;
      _activePendingList = false;
      _activeStatus = null;
      emit(BookingLoaded(booking));
    });
  }

  Future<void> _onCancelBooking(
    CancelBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());

    final params = CancelBookingParams(
      bookingId: event.bookingId,
      reason: event.reason,
    );
    final result = await _cancelBookingUseCase(params);

    result.fold(
      (failure) => emit(BookingFailure(failure.message)),
      (booking) =>
          emit(BookingActionSuccess(booking, 'Booking cancelled successfully')),
    );
  }

  Future<void> _onApproveBooking(
    ApproveBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());

    final params = ApproveBookingParams(
      bookingId: event.bookingId,
      message: event.message,
    );
    final result = await _approveBookingUseCase(params);

    result.fold(
      (failure) => emit(BookingFailure(failure.message)),
      (booking) =>
          emit(BookingActionSuccess(booking, 'Booking approved successfully')),
    );
  }

  Future<void> _onRejectBooking(
    RejectBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());

    final params = RejectBookingParams(
      bookingId: event.bookingId,
      reason: event.reason,
    );
    final result = await _rejectBookingUseCase(params);

    result.fold(
      (failure) => emit(BookingFailure(failure.message)),
      (booking) => emit(BookingActionSuccess(booking, 'Booking rejected')),
    );
  }

  void _onResetState(ResetBookingStateEvent event, Emitter<BookingState> emit) {
    emit(const BookingInitial());
  }

  void _rememberListKey({required bool owner, BookingStatus? status}) {
    final statusKey = status?.name ?? 'all';
    _activeCacheKey = owner
        ? 'bookings.owner:$statusKey'
        : 'bookings.renter:$statusKey';
    _activeOwnerList = owner;
    _activePendingList = false;
    _activeStatus = status;
    _activeBookingId = null;
  }

  void _onCacheChanged(String key) {
    if (key != _activeCacheKey ||
        (state is! BookingsLoaded && state is! BookingLoaded)) {
      return;
    }
    if (_activeBookingId != null) {
      add(LoadBookingByIdEvent(_activeBookingId!));
      return;
    }

    if (_activePendingList) {
      add(const LoadPendingBookingsEvent());
    } else if (_activeOwnerList) {
      add(LoadOwnerBookingsEvent(status: _activeStatus));
    } else {
      add(LoadRenterBookingsEvent(status: _activeStatus));
    }
  }

  @override
  Future<void> close() {
    _cacheSubscription.cancel();
    return super.close();
  }
}
