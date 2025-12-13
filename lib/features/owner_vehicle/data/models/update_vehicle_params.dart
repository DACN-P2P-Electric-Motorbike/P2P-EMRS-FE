import 'package:equatable/equatable.dart';
import '../../domain/entities/vehicle_entity.dart';

/// Parameters for updating a vehicle
class UpdateVehicleParams extends Equatable {
  final String? model;
  final VehicleType? type;
  final VehicleStatus? status;
  final int? batteryLevel;
  final double? pricePerHour;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? description;
  final List<String>? images;

  const UpdateVehicleParams({
    this.model,
    this.type,
    this.status,
    this.batteryLevel,
    this.pricePerHour,
    this.address,
    this.latitude,
    this.longitude,
    this.description,
    this.images,
  });

  /// Convert to JSON for API request (only include non-null values)
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (model != null) json['model'] = model;
    if (type != null) json['type'] = type!.toApiString();
    if (status != null) json['status'] = status!.toApiString();
    if (batteryLevel != null) json['batteryLevel'] = batteryLevel;
    if (pricePerHour != null) json['pricePerHour'] = pricePerHour;
    if (address != null) json['address'] = address;
    if (latitude != null) json['latitude'] = latitude;
    if (longitude != null) json['longitude'] = longitude;
    if (description != null) json['description'] = description;
    if (images != null) json['images'] = images;

    return json;
  }

  /// Create params for status update only
  factory UpdateVehicleParams.statusOnly(VehicleStatus newStatus) {
    return UpdateVehicleParams(status: newStatus);
  }

  /// Create params for battery update only
  factory UpdateVehicleParams.batteryOnly(int newBatteryLevel) {
    return UpdateVehicleParams(batteryLevel: newBatteryLevel);
  }

  @override
  List<Object?> get props => [
        model,
        type,
        status,
        batteryLevel,
        pricePerHour,
        address,
        latitude,
        longitude,
        description,
        images,
      ];
}

