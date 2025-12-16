import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/booking_usecases.dart';
import '../../domain/usecases/create_booking_usecase.dart';
import 'booking_event.dart';
import 'booking_state.dart';

/// Booking BLoC - handles booking state management
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final CreateBookingUseCase _createBookingUseCase;
  final GetRenterBookingsUseCase _getRenterBookingsUseCase;
  final GetOwnerBookingsUseCase _getOwnerBookingsUseCase;
  final GetPendingBookingsUseCase _getPendingBookingsUseCase;
  final GetBookingByIdUseCase _getBookingByIdUseCase;
  final CancelBookingUseCase _cancelBookingUseCase;
  final ApproveBookingUseCase _approveBookingUseCase;
  final RejectBookingUseCase _rejectBookingUseCase;

  BookingBloc({
    required CreateBookingUseCase createBookingUseCase,
    required GetRenterBookingsUseCase getRenterBookingsUseCase,
    required GetOwnerBookingsUseCase getOwnerBookingsUseCase,
    required GetPendingBookingsUseCase getPendingBookingsUseCase,
    required GetBookingByIdUseCase getBookingByIdUseCase,
    required CancelBookingUseCase cancelBookingUseCase,
    required ApproveBookingUseCase approveBookingUseCase,
    required RejectBookingUseCase rejectBookingUseCase,
  }) : _createBookingUseCase = createBookingUseCase,
       _getRenterBookingsUseCase = getRenterBookingsUseCase,
       _getOwnerBookingsUseCase = getOwnerBookingsUseCase,
       _getPendingBookingsUseCase = getPendingBookingsUseCase,
       _getBookingByIdUseCase = getBookingByIdUseCase,
       _cancelBookingUseCase = cancelBookingUseCase,
       _approveBookingUseCase = approveBookingUseCase,
       _rejectBookingUseCase = rejectBookingUseCase,
       super(const BookingInitial()) {
    on<CreateBookingEvent>(_onCreateBooking);
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
    );

    final result = await _createBookingUseCase(params);

    result.fold(
      (failure) => emit(BookingFailure(failure.message)),
      (booking) => emit(BookingCreated(booking)),
    );
  }

  Future<void> _onLoadRenterBookings(
    LoadRenterBookingsEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());

    final params = GetRenterBookingsParams(status: event.status);
    final result = await _getRenterBookingsUseCase(params);

    result.fold(
      (failure) => emit(BookingFailure(failure.message)),
      (bookings) => emit(BookingsLoaded(bookings)),
    );
  }

  Future<void> _onLoadOwnerBookings(
    LoadOwnerBookingsEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());

    final params = GetOwnerBookingsParams(status: event.status);
    final result = await _getOwnerBookingsUseCase(params);

    result.fold(
      (failure) => emit(BookingFailure(failure.message)),
      (bookings) => emit(BookingsLoaded(bookings)),
    );
  }

  Future<void> _onLoadPendingBookings(
    LoadPendingBookingsEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());

    final result = await _getPendingBookingsUseCase(const NoParams());

    result.fold(
      (failure) => emit(BookingFailure(failure.message)),
      (bookings) => emit(BookingsLoaded(bookings)),
    );
  }

  Future<void> _onLoadBookingById(
    LoadBookingByIdEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());

    final params = GetBookingByIdParams(event.bookingId);
    final result = await _getBookingByIdUseCase(params);

    result.fold(
      (failure) => emit(BookingFailure(failure.message)),
      (booking) => emit(BookingLoaded(booking)),
    );
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
}
