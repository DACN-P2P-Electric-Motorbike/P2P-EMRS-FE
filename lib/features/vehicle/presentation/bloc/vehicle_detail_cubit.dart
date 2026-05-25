import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/entities/availability_summary.dart';
import '../../domain/usecases/get_vehicle_by_id.dart';
import '../../domain/usecases/get_vehicle_availability_summary.dart';

// States
abstract class VehicleDetailState extends Equatable {
  const VehicleDetailState();

  @override
  List<Object?> get props => [];
}

class VehicleDetailInitial extends VehicleDetailState {}

class VehicleDetailLoading extends VehicleDetailState {}

class VehicleDetailLoaded extends VehicleDetailState {
  final VehicleEntity vehicle;
  final VehicleAvailabilitySummary? availabilitySummary;
  final bool isSaved;

  const VehicleDetailLoaded({
    required this.vehicle,
    this.availabilitySummary,
    this.isSaved = false,
  });

  VehicleDetailLoaded copyWith({
    VehicleEntity? vehicle,
    VehicleAvailabilitySummary? availabilitySummary,
    bool? isSaved,
  }) {
    return VehicleDetailLoaded(
      vehicle: vehicle ?? this.vehicle,
      availabilitySummary: availabilitySummary ?? this.availabilitySummary,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  List<Object?> get props => [vehicle, availabilitySummary, isSaved];
}

class VehicleDetailError extends VehicleDetailState {
  final String message;

  const VehicleDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class VehicleDetailCubit extends Cubit<VehicleDetailState> {
  final GetVehicleById _getVehicleById;
  final GetVehicleAvailabilitySummary _getAvailabilitySummary;

  VehicleDetailCubit({
    required GetVehicleById getVehicleById,
    required GetVehicleAvailabilitySummary getAvailabilitySummary,
  }) : _getVehicleById = getVehicleById,
       _getAvailabilitySummary = getAvailabilitySummary,
       super(VehicleDetailInitial());

  Future<void> loadVehicle(String vehicleId) async {
    emit(VehicleDetailLoading());

    final result = await _getVehicleById(GetVehicleByIdParams(id: vehicleId));

    await result.fold(
      (failure) async => emit(VehicleDetailError(failure.message)),
      (vehicle) async {
        emit(VehicleDetailLoaded(vehicle: vehicle));
        final summaryResult = await _getAvailabilitySummary(vehicleId);
        final summary = summaryResult.fold((_) => null, (value) => value);
        final currentState = state;
        if (summary != null &&
            currentState is VehicleDetailLoaded &&
            currentState.vehicle.id == vehicleId) {
          emit(currentState.copyWith(availabilitySummary: summary));
        }
      },
    );
  }

  void toggleSaved() {
    if (state is VehicleDetailLoaded) {
      final currentState = state as VehicleDetailLoaded;
      emit(currentState.copyWith(isSaved: !currentState.isSaved));

      // TODO: Implement actual save/unsave logic with repository
      // if (currentState.isSaved) {
      //   await repository.removeSavedVehicle(currentState.vehicle.id);
      // } else {
      //   await repository.saveVehicle(currentState.vehicle.id);
      // }
    }
  }

  void refreshVehicle() {
    if (state is VehicleDetailLoaded) {
      final vehicleId = (state as VehicleDetailLoaded).vehicle.id;
      loadVehicle(vehicleId);
    }
  }
}
