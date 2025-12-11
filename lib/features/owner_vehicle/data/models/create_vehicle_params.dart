import 'package:equatable/equatable.dart';
import '../../domain/entities/vehicle_entity.dart';

/// Parameters for creating a new vehicle
class CreateVehicleParams extends Equatable {
  final String licensePlate;
  final String model;
  final VehicleBrand brand;
  final VehicleType type;
  final List<VehicleFeature> features;
  final double pricePerHour;
  final double? pricePerDay;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? description;
  final List<String> images;
  final String? licenseNumber;
  final String? licenseFront;
  final String? licenseBack;
  final int? batteryLevel;

  const CreateVehicleParams({
    required this.licensePlate,
    required this.model,
    required this.brand,
    required this.type,
    this.features = const [],
    required this.pricePerHour,
    this.pricePerDay,
    required this.address,
    this.latitude,
    this.longitude,
    this.description,
    this.images = const [],
    this.licenseNumber,
    this.licenseFront,
    this.licenseBack,
    this.batteryLevel,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'licensePlate': licensePlate,
      'model': model,
      'brand': brand.toApiString(),
      'type': type.toApiString(),
      'pricePerHour': pricePerHour,
      'address': address,
      'images': images,
    };

    if (features.isNotEmpty) {
      json['features'] = features.map((f) => f.toApiString()).toList();
    }
    if (pricePerDay != null) json['pricePerDay'] = pricePerDay;
    if (latitude != null) json['latitude'] = latitude;
    if (longitude != null) json['longitude'] = longitude;
    if (description != null && description!.isNotEmpty) {
      json['description'] = description;
    }
    if (licenseNumber != null && licenseNumber!.isNotEmpty) {
      json['licenseNumber'] = licenseNumber;
    }
    if (licenseFront != null) json['licenseFront'] = licenseFront;
    if (licenseBack != null) json['licenseBack'] = licenseBack;
    if (batteryLevel != null) json['batteryLevel'] = batteryLevel;

    return json;
  }

  @override
  List<Object?> get props => [
        licensePlate,
        model,
        brand,
        type,
        features,
        pricePerHour,
        pricePerDay,
        address,
        latitude,
        longitude,
        description,
        images,
        licenseNumber,
        licenseFront,
        licenseBack,
        batteryLevel,
      ];
}
