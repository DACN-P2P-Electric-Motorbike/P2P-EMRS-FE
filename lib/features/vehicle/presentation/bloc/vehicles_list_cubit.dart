import 'package:fe_capstone_project/features/vehicle/domain/entities/vehicle_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_available_vehicles.dart';

// States
abstract class VehicleListState extends Equatable {
  const VehicleListState();

  @override
  List<Object?> get props => [];
}

class VehicleListInitial extends VehicleListState {}

class VehicleListLoading extends VehicleListState {}

class VehicleListLoaded extends VehicleListState {
  final List<VehicleEntity> vehicles;

  const VehicleListLoaded(this.vehicles);

  @override
  List<Object?> get props => [vehicles];
}

class VehicleListError extends VehicleListState {
  final String message;

  const VehicleListError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class VehicleListCubit extends Cubit<VehicleListState> {
  final GetAvailableVehicles _getAvailableVehicles;

  VehicleListCubit({required GetAvailableVehicles getAvailableVehicles})
    : _getAvailableVehicles = getAvailableVehicles,
      super(VehicleListInitial());

  Future<void> loadVehicles() async {
    emit(VehicleListLoading());

    final result = await _getAvailableVehicles(const NoParams());

    result.fold(
      (failure) => emit(VehicleListError(failure.message)),
      (vehicles) => emit(VehicleListLoaded(vehicles)),
    );
  }

  void filterVehicles(
    List<VehicleEntity> allVehicles, {
    String? searchQuery,
    double? maxPrice,
  }) {
    var filtered = allVehicles;

    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered.where((vehicle) {
        final query = searchQuery.toLowerCase();
        final brandQuery = VehicleBrand.tryParse(query);
        return (brandQuery != null && vehicle.brand == brandQuery) ||
            vehicle.model.toLowerCase().contains(query) ||
            vehicle.displayName.toLowerCase().contains(query);
      }).toList();
    }

    if (maxPrice != null) {
      filtered = filtered.where((vehicle) {
        return vehicle.pricePerHour <= maxPrice;
      }).toList();
    }

    emit(VehicleListLoaded(filtered));
  }
}
