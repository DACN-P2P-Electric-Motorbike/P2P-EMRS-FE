import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../data/models/create_vehicle_params.dart';
import '../../data/models/update_vehicle_params.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/usecases/get_my_vehicles_usecase.dart';
import '../../domain/usecases/get_vehicle_by_id_usecase.dart';
import '../../domain/usecases/register_vehicle_usecase.dart';
import '../../domain/usecases/update_vehicle_usecase.dart';

part 'owner_vehicle_event.dart';
part 'owner_vehicle_state.dart';

/// BLoC for managing owner vehicle operations
class OwnerVehicleBloc extends Bloc<OwnerVehicleEvent, OwnerVehicleState> {
  final GetMyVehiclesUseCase _getMyVehiclesUseCase;
  final RegisterVehicleUseCase _registerVehicleUseCase;
  final UpdateVehicleUseCase _updateVehicleUseCase;
  final GetVehicleByIdUseCase _getVehicleByIdUseCase;

  OwnerVehicleBloc({
    required GetMyVehiclesUseCase getMyVehiclesUseCase,
    required RegisterVehicleUseCase registerVehicleUseCase,
    required UpdateVehicleUseCase updateVehicleUseCase,
    required GetVehicleByIdUseCase getVehicleByIdUseCase,
  })  : _getMyVehiclesUseCase = getMyVehiclesUseCase,
        _registerVehicleUseCase = registerVehicleUseCase,
        _updateVehicleUseCase = updateVehicleUseCase,
        _getVehicleByIdUseCase = getVehicleByIdUseCase,
        super(OwnerVehicleState.initial()) {
    on<LoadMyVehicles>(_onLoadMyVehicles);
    on<RegisterVehicleSubmit>(_onRegisterVehicle);
    on<UpdateVehicleStatus>(_onUpdateVehicleStatus);
    on<UpdateVehicleBattery>(_onUpdateVehicleBattery);
    on<UpdateVehicleDetails>(_onUpdateVehicleDetails);
    on<LoadVehicleById>(_onLoadVehicleById);
    on<DeleteVehicle>(_onDeleteVehicle);
    on<ResetOwnerVehicleState>(_onResetState);
  }

  /// Handle loading my vehicles
  Future<void> _onLoadMyVehicles(
    LoadMyVehicles event,
    Emitter<OwnerVehicleState> emit,
  ) async {
    emit(state.copyWith(
      status: OwnerVehicleStatus.loading,
      clearError: true,
      clearSuccess: true,
    ));

    final result = await _getMyVehiclesUseCase(NoParams());

    result.fold(
      (failure) => emit(state.copyWith(
        status: OwnerVehicleStatus.error,
        errorMessage: failure.message,
      )),
      (vehicles) => emit(state.copyWith(
        status: OwnerVehicleStatus.loaded,
        vehicles: vehicles,
      )),
    );
  }

  /// Handle registering a new vehicle
  Future<void> _onRegisterVehicle(
    RegisterVehicleSubmit event,
    Emitter<OwnerVehicleState> emit,
  ) async {
    emit(state.copyWith(
      status: OwnerVehicleStatus.registering,
      clearError: true,
      clearSuccess: true,
    ));

    final result = await _registerVehicleUseCase(event.params);

    result.fold(
      (failure) => emit(state.copyWith(
        status: OwnerVehicleStatus.error,
        errorMessage: failure.message,
      )),
      (vehicle) {
        final updatedVehicles = [vehicle, ...state.vehicles];
        emit(state.copyWith(
          status: OwnerVehicleStatus.registered,
          vehicles: updatedVehicles,
          successMessage: 'Vehicle registered successfully! Pending approval.',
        ));
      },
    );
  }

  /// Handle updating vehicle status
  Future<void> _onUpdateVehicleStatus(
    UpdateVehicleStatus event,
    Emitter<OwnerVehicleState> emit,
  ) async {
    emit(state.copyWith(
      status: OwnerVehicleStatus.updating,
      clearError: true,
      clearSuccess: true,
    ));

    final params = UpdateVehicleUseCaseParams(
      vehicleId: event.vehicleId,
      updateParams: UpdateVehicleParams.statusOnly(event.newStatus),
    );

    final result = await _updateVehicleUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(
        status: OwnerVehicleStatus.error,
        errorMessage: failure.message,
      )),
      (updatedVehicle) {
        final updatedVehicles = state.vehicles.map((v) {
          return v.id == updatedVehicle.id ? updatedVehicle : v;
        }).toList();

        emit(state.copyWith(
          status: OwnerVehicleStatus.updated,
          vehicles: updatedVehicles,
          selectedVehicle:
              state.selectedVehicle?.id == updatedVehicle.id ? updatedVehicle : null,
          successMessage: 'Status updated to ${event.newStatus.displayName}',
        ));
      },
    );
  }

  /// Handle updating vehicle battery level
  Future<void> _onUpdateVehicleBattery(
    UpdateVehicleBattery event,
    Emitter<OwnerVehicleState> emit,
  ) async {
    emit(state.copyWith(
      status: OwnerVehicleStatus.updating,
      clearError: true,
      clearSuccess: true,
    ));

    final params = UpdateVehicleUseCaseParams(
      vehicleId: event.vehicleId,
      updateParams: UpdateVehicleParams.batteryOnly(event.batteryLevel),
    );

    final result = await _updateVehicleUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(
        status: OwnerVehicleStatus.error,
        errorMessage: failure.message,
      )),
      (updatedVehicle) {
        final updatedVehicles = state.vehicles.map((v) {
          return v.id == updatedVehicle.id ? updatedVehicle : v;
        }).toList();

        emit(state.copyWith(
          status: OwnerVehicleStatus.updated,
          vehicles: updatedVehicles,
          selectedVehicle:
              state.selectedVehicle?.id == updatedVehicle.id ? updatedVehicle : null,
          successMessage: 'Battery level updated to ${event.batteryLevel}%',
        ));
      },
    );
  }

  /// Handle updating vehicle details
  Future<void> _onUpdateVehicleDetails(
    UpdateVehicleDetails event,
    Emitter<OwnerVehicleState> emit,
  ) async {
    emit(state.copyWith(
      status: OwnerVehicleStatus.updating,
      clearError: true,
      clearSuccess: true,
    ));

    final params = UpdateVehicleUseCaseParams(
      vehicleId: event.vehicleId,
      updateParams: event.params,
    );

    final result = await _updateVehicleUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(
        status: OwnerVehicleStatus.error,
        errorMessage: failure.message,
      )),
      (updatedVehicle) {
        final updatedVehicles = state.vehicles.map((v) {
          return v.id == updatedVehicle.id ? updatedVehicle : v;
        }).toList();

        emit(state.copyWith(
          status: OwnerVehicleStatus.updated,
          vehicles: updatedVehicles,
          selectedVehicle: updatedVehicle,
          successMessage: 'Vehicle updated successfully',
        ));
      },
    );
  }

  /// Handle loading a vehicle by ID
  Future<void> _onLoadVehicleById(
    LoadVehicleById event,
    Emitter<OwnerVehicleState> emit,
  ) async {
    emit(state.copyWith(
      status: OwnerVehicleStatus.loading,
      clearError: true,
    ));

    final result = await _getVehicleByIdUseCase(event.vehicleId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: OwnerVehicleStatus.error,
        errorMessage: failure.message,
      )),
      (vehicle) => emit(state.copyWith(
        status: OwnerVehicleStatus.loaded,
        selectedVehicle: vehicle,
      )),
    );
  }

  /// Handle deleting a vehicle
  Future<void> _onDeleteVehicle(
    DeleteVehicle event,
    Emitter<OwnerVehicleState> emit,
  ) async {
    emit(state.copyWith(
      status: OwnerVehicleStatus.deleting,
      clearError: true,
      clearSuccess: true,
    ));

    // Note: Delete use case not implemented yet, using update as placeholder
    // In real implementation, you would call a delete use case here

    final updatedVehicles =
        state.vehicles.where((v) => v.id != event.vehicleId).toList();

    emit(state.copyWith(
      status: OwnerVehicleStatus.deleted,
      vehicles: updatedVehicles,
      clearSelectedVehicle: true,
      successMessage: 'Vehicle deleted successfully',
    ));
  }

  /// Handle resetting state
  void _onResetState(
    ResetOwnerVehicleState event,
    Emitter<OwnerVehicleState> emit,
  ) {
    emit(state.copyWith(
      status: OwnerVehicleStatus.loaded,
      clearError: true,
      clearSuccess: true,
    ));
  }
}

