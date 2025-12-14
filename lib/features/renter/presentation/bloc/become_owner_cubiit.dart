import 'package:fe_capstone_project/features/owner_vehicle/data/models/create_vehicle_params.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/become_owner_response_model.dart';
import '../../domain/usecases/become_owner.dart';

// States
abstract class BecomeOwnerState extends Equatable {
  const BecomeOwnerState();

  @override
  List<Object?> get props => [];
}

class BecomeOwnerInitial extends BecomeOwnerState {}

class BecomeOwnerLoading extends BecomeOwnerState {}

class BecomeOwnerSuccess extends BecomeOwnerState {
  final BecomeOwnerResponseDto response;

  const BecomeOwnerSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class BecomeOwnerError extends BecomeOwnerState {
  final String message;

  const BecomeOwnerError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class BecomeOwnerCubit extends Cubit<BecomeOwnerState> {
  final BecomeOwner _becomeOwner;

  BecomeOwnerCubit({required BecomeOwner becomeOwner})
    : _becomeOwner = becomeOwner,
      super(BecomeOwnerInitial());

  /// Submit become owner request with vehicle data
  /// Uses CreateVehicleParams to reuse vehicle data structure
  Future<void> submitBecomeOwner(CreateVehicleParams params) async {
    emit(BecomeOwnerLoading());

    final result = await _becomeOwner(params);

    result.fold(
      (failure) => emit(BecomeOwnerError(failure.message)),
      (response) => emit(BecomeOwnerSuccess(response)),
    );
  }

  void reset() {
    emit(BecomeOwnerInitial());
  }
}
