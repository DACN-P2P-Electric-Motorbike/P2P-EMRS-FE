import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/usecases/get_vehicle_by_id.dart';

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
  final bool isSaved;

  const VehicleDetailLoaded({required this.vehicle, this.isSaved = false});

  VehicleDetailLoaded copyWith({VehicleEntity? vehicle, bool? isSaved}) {
    return VehicleDetailLoaded(
      vehicle: vehicle ?? this.vehicle,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  List<Object?> get props => [vehicle, isSaved];
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

  VehicleDetailCubit({required GetVehicleById getVehicleById})
    : _getVehicleById = getVehicleById,
      super(VehicleDetailInitial());

  Future<void> loadVehicle(String vehicleId) async {
    emit(VehicleDetailLoading());

    final result = await _getVehicleById(GetVehicleByIdParams(id: vehicleId));

    result.fold(
      (failure) => emit(VehicleDetailError(failure.message)),
      (vehicle) => emit(VehicleDetailLoaded(vehicle: vehicle)),
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
