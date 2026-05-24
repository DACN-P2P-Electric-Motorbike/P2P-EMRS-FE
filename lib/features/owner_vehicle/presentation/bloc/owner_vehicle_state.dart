part of 'owner_vehicle_bloc.dart';

/// Status enum for owner vehicle operations
enum OwnerVehicleStatus {
  initial,
  loading,
  loaded,
  registering,
  registered,
  updating,
  updated,
  deleting,
  deleted,
  error,
}

/// State class for owner vehicle BLoC
class OwnerVehicleState extends Equatable {
  final OwnerVehicleStatus status;
  final List<VehicleEntity> vehicles;
  final List<VehicleAvailabilityWindowEntity> availabilityWindows;
  final VehicleEntity? selectedVehicle;
  final bool isAvailabilityLoading;
  final String? errorMessage;
  final String? successMessage;

  const OwnerVehicleState({
    this.status = OwnerVehicleStatus.initial,
    this.vehicles = const [],
    this.availabilityWindows = const [],
    this.selectedVehicle,
    this.isAvailabilityLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  /// Initial state
  factory OwnerVehicleState.initial() {
    return const OwnerVehicleState();
  }

  /// Create a copy with updated values
  OwnerVehicleState copyWith({
    OwnerVehicleStatus? status,
    List<VehicleEntity>? vehicles,
    List<VehicleAvailabilityWindowEntity>? availabilityWindows,
    VehicleEntity? selectedVehicle,
    bool? isAvailabilityLoading,
    String? errorMessage,
    String? successMessage,
    bool clearSelectedVehicle = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return OwnerVehicleState(
      status: status ?? this.status,
      vehicles: vehicles ?? this.vehicles,
      availabilityWindows: availabilityWindows ?? this.availabilityWindows,
      selectedVehicle: clearSelectedVehicle
          ? null
          : (selectedVehicle ?? this.selectedVehicle),
      isAvailabilityLoading:
          isAvailabilityLoading ?? this.isAvailabilityLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  /// Check if currently loading
  bool get isLoading =>
      status == OwnerVehicleStatus.loading ||
      status == OwnerVehicleStatus.registering ||
      status == OwnerVehicleStatus.updating ||
      status == OwnerVehicleStatus.deleting;

  /// Check if has vehicles
  bool get hasVehicles => vehicles.isNotEmpty;

  /// Get vehicles count
  int get vehicleCount => vehicles.length;

  /// Get available vehicles count
  int get availableCount =>
      vehicles.where((v) => v.status == VehicleStatus.available).length;

  /// Get pending vehicles count
  int get pendingCount =>
      vehicles.where((v) => v.status == VehicleStatus.pendingApproval).length;

  @override
  List<Object?> get props => [
    status,
    vehicles,
    availabilityWindows,
    selectedVehicle,
    isAvailabilityLoading,
    errorMessage,
    successMessage,
  ];
}
