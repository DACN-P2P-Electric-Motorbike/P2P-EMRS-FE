import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../domain/entities/vehicle_entity.dart';
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
    VehicleBrand? brand,
    VehicleType? type,
    int? minBatteryLevel,
    List<VehicleFeature>? features,
    String sortBy = 'default',
  }) {
    var filtered = List<VehicleEntity>.from(allVehicles);

    // Apply search filter
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered.where((vehicle) {
        final query = searchQuery.toLowerCase();

        // Try to parse as brand
        final brandQuery = VehicleBrand.tryParse(query);
        if (brandQuery != null && vehicle.brand == brandQuery) {
          return true;
        }

        // Search in model, name, and display name
        return vehicle.model.toLowerCase().contains(query) ||
            (vehicle.name?.toLowerCase().contains(query) ?? false) ||
            vehicle.displayName.toLowerCase().contains(query) ||
            vehicle.licensePlate.toLowerCase().contains(query);
      }).toList();
    }

    // Apply brand filter
    if (brand != null) {
      filtered = filtered.where((vehicle) {
        return vehicle.brand.toApiString() == brand;
      }).toList();
    }

    // Apply type filter
    if (type != null) {
      filtered = filtered.where((vehicle) {
        return vehicle.type == type;
      }).toList();
    }

    // Apply price filter
    if (maxPrice != null) {
      filtered = filtered.where((vehicle) {
        return vehicle.pricePerHour <= maxPrice;
      }).toList();
    }

    // Apply battery level filter
    if (minBatteryLevel != null) {
      filtered = filtered.where((vehicle) {
        return vehicle.batteryLevel >= minBatteryLevel;
      }).toList();
    }

    // Apply features filter
    if (features != null && features.isNotEmpty) {
      filtered = filtered.where((vehicle) {
        // Vehicle must have all selected features
        return features.every((feature) => vehicle.features.contains(feature));
      }).toList();
    }

    // Apply status filter - only show available vehicles
    filtered = filtered.where((vehicle) {
      return vehicle.isAvailable && vehicle.status == VehicleStatus.available;
    }).toList();

    // Apply sorting
    switch (sortBy) {
      case 'price_low':
        filtered.sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
        break;
      case 'price_high':
        filtered.sort((a, b) => b.pricePerHour.compareTo(a.pricePerHour));
        break;
      case 'rating':
        filtered.sort((a, b) {
          final ratingA = a.reviewCount > 0
              ? a.totalRating / a.reviewCount
              : a.totalRating;
          final ratingB = b.reviewCount > 0
              ? b.totalRating / b.reviewCount
              : b.totalRating;
          return ratingB.compareTo(ratingA);
        });
        break;
      case 'distance':
        // TODO: Implement distance sorting when location is available
        // For now, keep default order
        break;
      case 'default':
      default:
        // Keep original order (or sort by created date)
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    emit(VehicleListLoaded(filtered));
  }
}
