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
  final bool instantBook;
  final int? dailyKmLimit;
  final double? excessKmPrice;
  final double? weeklyDiscount;
  final double? monthlyDiscount;
  final bool allowSmoke;
  final bool allowPets;
  final String? geoRestriction;
  final int? batteryReturnMin;
  final int? firstRegistrationYear;
  final VehicleCondition? condition;
  final BatteryType? batteryType;
  final int? batteryHealth;
  final int? batteryCycleCount;
  final DateTime? batteryLastServicedAt;
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
    this.instantBook = false,
    this.dailyKmLimit,
    this.excessKmPrice,
    this.weeklyDiscount,
    this.monthlyDiscount,
    this.allowSmoke = false,
    this.allowPets = false,
    this.geoRestriction,
    this.batteryReturnMin,
    this.firstRegistrationYear,
    this.condition,
    this.batteryType,
    this.batteryHealth,
    this.batteryCycleCount,
    this.batteryLastServicedAt,
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
      'instantBook': instantBook,
      'allowSmoke': allowSmoke,
      'allowPets': allowPets,
      'address': address,
      'images': images,
    };

    if (features.isNotEmpty) {
      json['features'] = features.map((f) => f.toApiString()).toList();
    }
    if (pricePerDay != null) json['pricePerDay'] = pricePerDay;
    if (dailyKmLimit != null) json['dailyKmLimit'] = dailyKmLimit;
    if (excessKmPrice != null) json['excessKmPrice'] = excessKmPrice;
    if (weeklyDiscount != null) json['weeklyDiscount'] = weeklyDiscount;
    if (monthlyDiscount != null) json['monthlyDiscount'] = monthlyDiscount;
    if (geoRestriction != null && geoRestriction!.isNotEmpty) {
      json['geoRestriction'] = geoRestriction;
    }
    if (batteryReturnMin != null) json['batteryReturnMin'] = batteryReturnMin;
    if (firstRegistrationYear != null) {
      json['firstRegistrationYear'] = firstRegistrationYear;
    }
    if (condition != null) json['condition'] = condition!.toApiString();
    if (batteryType != null) json['batteryType'] = batteryType!.toApiString();
    if (batteryHealth != null) json['batteryHealth'] = batteryHealth;
    if (batteryCycleCount != null) {
      json['batteryCycleCount'] = batteryCycleCount;
    }
    if (batteryLastServicedAt != null) {
      json['batteryLastServicedAt'] = batteryLastServicedAt!
          .toUtc()
          .toIso8601String();
    }
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
    instantBook,
    dailyKmLimit,
    excessKmPrice,
    weeklyDiscount,
    monthlyDiscount,
    allowSmoke,
    allowPets,
    geoRestriction,
    batteryReturnMin,
    firstRegistrationYear,
    condition,
    batteryType,
    batteryHealth,
    batteryCycleCount,
    batteryLastServicedAt,
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
