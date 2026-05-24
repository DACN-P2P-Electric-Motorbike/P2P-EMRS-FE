import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/handover.dart';
import '../../domain/usecases/handover_usecases.dart';
import 'handover_state.dart';

class HandoverCubit extends Cubit<HandoverState> {
  final GetHandoverByBookingUseCase _getByBooking;
  final CreateCheckInUseCase _createCheckIn;
  final CreateCheckOutUseCase _createCheckOut;
  final ConfirmHandoverUseCase _confirm;

  HandoverCubit({
    required GetHandoverByBookingUseCase getByBooking,
    required CreateCheckInUseCase createCheckIn,
    required CreateCheckOutUseCase createCheckOut,
    required ConfirmHandoverUseCase confirm,
  }) : _getByBooking = getByBooking,
       _createCheckIn = createCheckIn,
       _createCheckOut = createCheckOut,
       _confirm = confirm,
       super(const HandoverState());

  Future<void> load(String bookingId) async {
    emit(state.copyWith(status: HandoverViewStatus.loading, clearError: true));
    final result = await _getByBooking(GetHandoverByBookingParams(bookingId));
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: HandoverViewStatus.loaded,
          errorMessage: failure.message,
        ),
      ),
      (summary) => emit(
        state.copyWith(
          status: HandoverViewStatus.loaded,
          summary: summary,
          clearError: true,
        ),
      ),
    );
  }

  Future<VehicleHandover?> createCheckIn(HandoverMutationParams params) async {
    return _mutate(() => _createCheckIn(params), bookingId: params.bookingId);
  }

  Future<VehicleHandover?> createCheckOut(HandoverMutationParams params) async {
    return _mutate(() => _createCheckOut(params), bookingId: params.bookingId);
  }

  Future<VehicleHandover?> confirm({
    required String handoverId,
    required String bookingId,
  }) async {
    return _mutate(
      () => _confirm(ConfirmHandoverParams(handoverId)),
      bookingId: bookingId,
    );
  }

  Future<VehicleHandover?> _mutate(
    Future<Either<Failure, VehicleHandover>> Function() call, {
    required String bookingId,
  }) async {
    emit(
      state.copyWith(status: HandoverViewStatus.submitting, clearError: true),
    );
    final result = await call();
    VehicleHandover? handover;
    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            status: HandoverViewStatus.loaded,
            errorMessage: failure.message,
          ),
        );
      },
      (updated) async {
        handover = updated;
        emit(
          state.copyWith(
            status: HandoverViewStatus.success,
            latestHandover: handover,
            clearError: true,
          ),
        );
        await load(bookingId);
      },
    );
    return handover;
  }
}
