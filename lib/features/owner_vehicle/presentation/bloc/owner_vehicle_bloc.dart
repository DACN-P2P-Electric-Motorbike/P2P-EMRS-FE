import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cache/hive_cache_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/availability_window_model.dart';
import '../../data/models/create_vehicle_params.dart';
import '../../data/models/update_vehicle_params.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/usecases/delete_vehicle_usecase.dart';
import '../../domain/usecases/get_my_vehicles_usecase.dart';
import '../../domain/usecases/get_vehicle_by_id_usecase.dart';
import '../../domain/usecases/register_vehicle_usecase.dart';
import '../../domain/usecases/toggle_availability_usecase.dart';
import '../../domain/usecases/update_vehicle_usecase.dart';
import '../../domain/usecases/vehicle_availability_usecases.dart';

part 'owner_vehicle_event.dart';
part 'owner_vehicle_state.dart';

/// BLoC for managing owner vehicle operations
class OwnerVehicleBloc extends Bloc<OwnerVehicleEvent, OwnerVehicleState> {
  final GetMyVehiclesUseCase _getMyVehiclesUseCase;
  final RegisterVehicleUseCase _registerVehicleUseCase;
  final UpdateVehicleUseCase _updateVehicleUseCase;
  final GetVehicleByIdUseCase _getVehicleByIdUseCase;
  final ToggleAvailabilityUseCase _toggleAvailabilityUseCase;
  final GetVehicleAvailabilityUseCase _getVehicleAvailabilityUseCase;
  final CreateVehicleAvailabilityUseCase _createVehicleAvailabilityUseCase;
  final UpdateVehicleAvailabilityUseCase _updateVehicleAvailabilityUseCase;
  final DeleteVehicleAvailabilityUseCase _deleteVehicleAvailabilityUseCase;
  final DeleteVehicleUseCase _deleteVehicleUseCase;
  final HiveCacheService _cache;
  late final StreamSubscription<String> _cacheSubscription;
  bool _isWatchingMyVehicles = false;

  OwnerVehicleBloc({
    required GetMyVehiclesUseCase getMyVehiclesUseCase,
    required RegisterVehicleUseCase registerVehicleUseCase,
    required UpdateVehicleUseCase updateVehicleUseCase,
    required GetVehicleByIdUseCase getVehicleByIdUseCase,
    required ToggleAvailabilityUseCase toggleAvailabilityUseCase,
    required GetVehicleAvailabilityUseCase getVehicleAvailabilityUseCase,
    required CreateVehicleAvailabilityUseCase createVehicleAvailabilityUseCase,
    required UpdateVehicleAvailabilityUseCase updateVehicleAvailabilityUseCase,
    required DeleteVehicleAvailabilityUseCase deleteVehicleAvailabilityUseCase,
    required DeleteVehicleUseCase deleteVehicleUseCase,
    required HiveCacheService cache,
  }) : _getMyVehiclesUseCase = getMyVehiclesUseCase,
       _registerVehicleUseCase = registerVehicleUseCase,
       _updateVehicleUseCase = updateVehicleUseCase,
       _getVehicleByIdUseCase = getVehicleByIdUseCase,
       _toggleAvailabilityUseCase = toggleAvailabilityUseCase,
       _getVehicleAvailabilityUseCase = getVehicleAvailabilityUseCase,
       _createVehicleAvailabilityUseCase = createVehicleAvailabilityUseCase,
       _updateVehicleAvailabilityUseCase = updateVehicleAvailabilityUseCase,
       _deleteVehicleAvailabilityUseCase = deleteVehicleAvailabilityUseCase,
       _deleteVehicleUseCase = deleteVehicleUseCase,
       _cache = cache,
       super(OwnerVehicleState.initial()) {
    _cacheSubscription = _cache.changes.listen(_onCacheChanged);
    on<LoadMyVehicles>(_onLoadMyVehicles);
    on<RegisterVehicleSubmit>(_onRegisterVehicle);
    on<UpdateVehicleStatus>(_onUpdateVehicleStatus);
    on<UpdateVehicleBattery>(_onUpdateVehicleBattery);
    on<UpdateVehicleDetails>(_onUpdateVehicleDetails);
    on<LoadVehicleById>(_onLoadVehicleById);
    on<DeleteVehicle>(_onDeleteVehicle);
    on<ToggleVehicleAvailability>(_onToggleAvailability);
    on<LoadVehicleAvailability>(_onLoadVehicleAvailability);
    on<CreateVehicleAvailability>(_onCreateVehicleAvailability);
    on<UpdateVehicleAvailability>(_onUpdateVehicleAvailability);
    on<DeleteVehicleAvailability>(_onDeleteVehicleAvailability);
    on<ResetOwnerVehicleState>(_onResetState);
  }

  /// Handle loading my vehicles
  Future<void> _onLoadMyVehicles(
    LoadMyVehicles event,
    Emitter<OwnerVehicleState> emit,
  ) async {
    emit(
      state.copyWith(
        status: OwnerVehicleStatus.loading,
        clearError: true,
        clearSuccess: true,
      ),
    );

    final result = await _getMyVehiclesUseCase(NoParams());

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: OwnerVehicleStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (vehicles) => emit(
        state.copyWith(status: OwnerVehicleStatus.loaded, vehicles: vehicles),
      ),
    );
    _isWatchingMyVehicles = true;
  }

  /// Handle registering a new vehicle
  Future<void> _onRegisterVehicle(
    RegisterVehicleSubmit event,
    Emitter<OwnerVehicleState> emit,
  ) async {
    emit(
      state.copyWith(
        status: OwnerVehicleStatus.registering,
        clearError: true,
        clearSuccess: true,
      ),
    );

    final result = await _registerVehicleUseCase(event.params);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: OwnerVehicleStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (vehicle) {
        final updatedVehicles = [vehicle, ...state.vehicles];
        emit(
          state.copyWith(
            status: OwnerVehicleStatus.registered,
            vehicles: updatedVehicles,
            successMessage: 'Đã gửi xe để chờ duyệt.',
          ),
        );
      },
    );
  }

  /// Handle updating vehicle status
  Future<void> _onUpdateVehicleStatus(
    UpdateVehicleStatus event,
    Emitter<OwnerVehicleState> emit,
  ) async {
    emit(
      state.copyWith(
        status: OwnerVehicleStatus.updating,
        clearError: true,
        clearSuccess: true,
      ),
    );

    final params = UpdateVehicleUseCaseParams(
      vehicleId: event.vehicleId,
      updateParams: UpdateVehicleParams.statusOnly(event.newStatus),
    );

    final result = await _updateVehicleUseCase(params);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: OwnerVehicleStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (updatedVehicle) {
        final updatedVehicles = state.vehicles.map((v) {
          return v.id == updatedVehicle.id ? updatedVehicle : v;
        }).toList();

        emit(
          state.copyWith(
            status: OwnerVehicleStatus.updated,
            vehicles: updatedVehicles,
            selectedVehicle: state.selectedVehicle?.id == updatedVehicle.id
                ? updatedVehicle
                : null,
            successMessage:
                'Đã cập nhật trạng thái: ${event.newStatus.displayName}',
          ),
        );
      },
    );
  }

  /// Handle updating vehicle battery level
  Future<void> _onUpdateVehicleBattery(
    UpdateVehicleBattery event,
    Emitter<OwnerVehicleState> emit,
  ) async {
    emit(
      state.copyWith(
        status: OwnerVehicleStatus.updating,
        clearError: true,
        clearSuccess: true,
      ),
    );

    final params = UpdateVehicleUseCaseParams(
      vehicleId: event.vehicleId,
      updateParams: UpdateVehicleParams.batteryOnly(event.batteryLevel),
    );

    final result = await _updateVehicleUseCase(params);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: OwnerVehicleStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (updatedVehicle) {
        final updatedVehicles = state.vehicles.map((v) {
          return v.id == updatedVehicle.id ? updatedVehicle : v;
        }).toList();

        emit(
          state.copyWith(
            status: OwnerVehicleStatus.updated,
            vehicles: updatedVehicles,
            selectedVehicle: state.selectedVehicle?.id == updatedVehicle.id
                ? updatedVehicle
                : null,
            successMessage: 'Battery level updated to ${event.batteryLevel}%',
          ),
        );
      },
    );
  }

  /// Handle updating vehicle details
  Future<void> _onUpdateVehicleDetails(
    UpdateVehicleDetails event,
    Emitter<OwnerVehicleState> emit,
  ) async {
    emit(
      state.copyWith(
        status: OwnerVehicleStatus.updating,
        clearError: true,
        clearSuccess: true,
      ),
    );

    final params = UpdateVehicleUseCaseParams(
      vehicleId: event.vehicleId,
      updateParams: event.params,
    );

    final result = await _updateVehicleUseCase(params);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: OwnerVehicleStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (updatedVehicle) {
        final updatedVehicles = state.vehicles.map((v) {
          return v.id == updatedVehicle.id ? updatedVehicle : v;
        }).toList();

        emit(
          state.copyWith(
            status: OwnerVehicleStatus.updated,
            vehicles: updatedVehicles,
            selectedVehicle: updatedVehicle,
            successMessage: 'Vehicle updated successfully',
          ),
        );
      },
    );
  }

  /// Handle loading a vehicle by ID
  Future<void> _onLoadVehicleById(
    LoadVehicleById event,
    Emitter<OwnerVehicleState> emit,
  ) async {
    emit(state.copyWith(status: OwnerVehicleStatus.loading, clearError: true));

    final result = await _getVehicleByIdUseCase(event.vehicleId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: OwnerVehicleStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (vehicle) => emit(
        state.copyWith(
          status: OwnerVehicleStatus.loaded,
          selectedVehicle: vehicle,
        ),
      ),
    );
  }

  /// Handle deleting a vehicle
  Future<void> _onDeleteVehicle(
    DeleteVehicle event,
    Emitter<OwnerVehicleState> emit,
  ) async {
    emit(
      state.copyWith(
        status: OwnerVehicleStatus.deleting,
        clearError: true,
        clearSuccess: true,
      ),
    );

    final result = await _deleteVehicleUseCase(event.vehicleId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: OwnerVehicleStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        final updatedVehicles = state.vehicles
            .where((v) => v.id != event.vehicleId)
            .toList();

        emit(
          state.copyWith(
            status: OwnerVehicleStatus.deleted,
            vehicles: updatedVehicles,
            clearSelectedVehicle: true,
            successMessage: 'Vehicle deleted successfully',
          ),
        );
      },
    );
  }

  /// Handle toggling vehicle availability
  Future<void> _onToggleAvailability(
    ToggleVehicleAvailability event,
    Emitter<OwnerVehicleState> emit,
  ) async {
    emit(
      state.copyWith(
        status: OwnerVehicleStatus.updating,
        clearError: true,
        clearSuccess: true,
      ),
    );

    final result = await _toggleAvailabilityUseCase(event.vehicleId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: OwnerVehicleStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (updatedVehicle) {
        final updatedVehicles = state.vehicles.map((v) {
          return v.id == updatedVehicle.id ? updatedVehicle : v;
        }).toList();

        final statusText = updatedVehicle.isAvailable
            ? 'Xe đã sẵn sàng cho thuê'
            : 'Đã tắt cho thuê xe';

        emit(
          state.copyWith(
            status: OwnerVehicleStatus.updated,
            vehicles: updatedVehicles,
            selectedVehicle: state.selectedVehicle?.id == updatedVehicle.id
                ? updatedVehicle
                : null,
            successMessage: statusText,
          ),
        );
      },
    );
  }

  Future<void> _onLoadVehicleAvailability(
    LoadVehicleAvailability event,
    Emitter<OwnerVehicleState> emit,
  ) async {
    emit(state.copyWith(isAvailabilityLoading: true, clearError: true));

    final result = await _getVehicleAvailabilityUseCase(event.vehicleId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          isAvailabilityLoading: false,
          errorMessage: failure.message,
        ),
      ),
      (windows) => emit(
        state.copyWith(
          isAvailabilityLoading: false,
          availabilityWindows: windows,
        ),
      ),
    );
  }

  Future<void> _onCreateVehicleAvailability(
    CreateVehicleAvailability event,
    Emitter<OwnerVehicleState> emit,
  ) async {
    emit(
      state.copyWith(
        status: OwnerVehicleStatus.updating,
        isAvailabilityLoading: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    final result = await _createVehicleAvailabilityUseCase(
      CreateVehicleAvailabilityParams(
        vehicleId: event.vehicleId,
        windowParams: event.params,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: OwnerVehicleStatus.error,
          isAvailabilityLoading: false,
          errorMessage: failure.message,
        ),
      ),
      (window) {
        final windows = [...state.availabilityWindows, window]
          ..sort((a, b) => a.startTime.compareTo(b.startTime));
        emit(
          state.copyWith(
            status: OwnerVehicleStatus.updated,
            isAvailabilityLoading: false,
            availabilityWindows: windows,
            successMessage: 'Đã cập nhật lịch cho thuê',
          ),
        );
      },
    );
  }

  Future<void> _onDeleteVehicleAvailability(
    DeleteVehicleAvailability event,
    Emitter<OwnerVehicleState> emit,
  ) async {
    emit(
      state.copyWith(
        status: OwnerVehicleStatus.updating,
        isAvailabilityLoading: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    final result = await _deleteVehicleAvailabilityUseCase(
      DeleteVehicleAvailabilityParams(
        vehicleId: event.vehicleId,
        windowId: event.windowId,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: OwnerVehicleStatus.error,
          isAvailabilityLoading: false,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        final windows = state.availabilityWindows
            .where((window) => window.id != event.windowId)
            .toList();
        emit(
          state.copyWith(
            status: OwnerVehicleStatus.updated,
            isAvailabilityLoading: false,
            availabilityWindows: windows,
            successMessage: 'Đã xóa khung lịch',
          ),
        );
      },
    );
  }

  Future<void> _onUpdateVehicleAvailability(
    UpdateVehicleAvailability event,
    Emitter<OwnerVehicleState> emit,
  ) async {
    emit(
      state.copyWith(
        status: OwnerVehicleStatus.updating,
        isAvailabilityLoading: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    final result = await _updateVehicleAvailabilityUseCase(
      UpdateVehicleAvailabilityParams(
        vehicleId: event.vehicleId,
        windowId: event.windowId,
        windowParams: event.params,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: OwnerVehicleStatus.error,
          isAvailabilityLoading: false,
          errorMessage: failure.message,
        ),
      ),
      (updatedWindow) {
        final windows =
            state.availabilityWindows
                .map(
                  (window) =>
                      window.id == updatedWindow.id ? updatedWindow : window,
                )
                .toList()
              ..sort((a, b) => a.startTime.compareTo(b.startTime));
        emit(
          state.copyWith(
            status: OwnerVehicleStatus.updated,
            isAvailabilityLoading: false,
            availabilityWindows: windows,
            successMessage: 'Đã sửa lịch cho thuê',
          ),
        );
      },
    );
  }

  /// Handle resetting state
  void _onResetState(
    ResetOwnerVehicleState event,
    Emitter<OwnerVehicleState> emit,
  ) {
    emit(
      state.copyWith(
        status: OwnerVehicleStatus.loaded,
        clearError: true,
        clearSuccess: true,
      ),
    );
  }

  void _onCacheChanged(String key) {
    if (!_isWatchingMyVehicles ||
        key != 'owner.vehicles' ||
        state.status != OwnerVehicleStatus.loaded) {
      return;
    }
    add(const LoadMyVehicles());
  }

  @override
  Future<void> close() {
    _cacheSubscription.cancel();
    return super.close();
  }
}
