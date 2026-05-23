part of 'owner_vehicle_bloc.dart';

/// Base class for owner vehicle events
abstract class OwnerVehicleEvent extends Equatable {
  const OwnerVehicleEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all vehicles owned by current user
class LoadMyVehicles extends OwnerVehicleEvent {
  const LoadMyVehicles();
}

/// Event to register a new vehicle
class RegisterVehicleSubmit extends OwnerVehicleEvent {
  final CreateVehicleParams params;

  const RegisterVehicleSubmit({required this.params});

  @override
  List<Object?> get props => [params];
}

/// Event to update vehicle status
class UpdateVehicleStatus extends OwnerVehicleEvent {
  final String vehicleId;
  final VehicleStatus newStatus;

  const UpdateVehicleStatus({required this.vehicleId, required this.newStatus});

  @override
  List<Object?> get props => [vehicleId, newStatus];
}

/// Event to update vehicle battery level
class UpdateVehicleBattery extends OwnerVehicleEvent {
  final String vehicleId;
  final int batteryLevel;

  const UpdateVehicleBattery({
    required this.vehicleId,
    required this.batteryLevel,
  });

  @override
  List<Object?> get props => [vehicleId, batteryLevel];
}

/// Event to update vehicle details
class UpdateVehicleDetails extends OwnerVehicleEvent {
  final String vehicleId;
  final UpdateVehicleParams params;

  const UpdateVehicleDetails({required this.vehicleId, required this.params});

  @override
  List<Object?> get props => [vehicleId, params];
}

/// Event to load a single vehicle by ID
class LoadVehicleById extends OwnerVehicleEvent {
  final String vehicleId;

  const LoadVehicleById(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

/// Event to delete a vehicle
class DeleteVehicle extends OwnerVehicleEvent {
  final String vehicleId;

  const DeleteVehicle(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

/// Event to toggle vehicle availability (on/off for rent)
class ToggleVehicleAvailability extends OwnerVehicleEvent {
  final String vehicleId;

  const ToggleVehicleAvailability(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

/// Event to load owner-managed availability windows
class LoadVehicleAvailability extends OwnerVehicleEvent {
  final String vehicleId;

  const LoadVehicleAvailability(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

/// Event to create an owner-managed availability window
class CreateVehicleAvailability extends OwnerVehicleEvent {
  final String vehicleId;
  final CreateAvailabilityWindowParams params;

  const CreateVehicleAvailability({
    required this.vehicleId,
    required this.params,
  });

  @override
  List<Object?> get props => [vehicleId, params];
}

/// Event to delete an owner-managed availability window
class DeleteVehicleAvailability extends OwnerVehicleEvent {
  final String vehicleId;
  final String windowId;

  const DeleteVehicleAvailability({
    required this.vehicleId,
    required this.windowId,
  });

  @override
  List<Object?> get props => [vehicleId, windowId];
}

/// Event to reset state (clear messages)
class ResetOwnerVehicleState extends OwnerVehicleEvent {
  const ResetOwnerVehicleState();
}
