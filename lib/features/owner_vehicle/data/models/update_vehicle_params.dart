import 'package:equatable/equatable.dart';
import '../../domain/entities/vehicle_entity.dart';

/// Parameters for updating a vehicle
class UpdateVehicleParams extends Equatable {
  final String? model;
  final VehicleType? type;
  final VehicleStatus? status;
  final int? batteryLevel;
  final double? pricePerHour;
  final double? pricePerDay;
  final bool? instantBook;
  final int? dailyKmLimit;
  final double? excessKmPrice;
  final double? weeklyDiscount;
  final double? monthlyDiscount;
  final bool? allowSmoke;
  final bool? allowPets;
  final String? geoRestriction;
  final int? batteryReturnMin;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? description;
  final List<String>? images;
  final Set<String> fieldsToClear;

  const UpdateVehicleParams({
    this.model,
    this.type,
    this.status,
    this.batteryLevel,
    this.pricePerHour,
    this.pricePerDay,
    this.instantBook,
    this.dailyKmLimit,
    this.excessKmPrice,
    this.weeklyDiscount,
    this.monthlyDiscount,
    this.allowSmoke,
    this.allowPets,
    this.geoRestriction,
    this.batteryReturnMin,
    this.address,
    this.latitude,
    this.longitude,
    this.description,
    this.images,
    this.fieldsToClear = const {},
  });

  /// Convert to JSON for API request (only include non-null values)
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (model != null) json['model'] = model;
    if (type != null) json['type'] = type!.toApiString();
    if (status != null) json['status'] = status!.toApiString();
    if (batteryLevel != null) json['batteryLevel'] = batteryLevel;
    if (pricePerHour != null) json['pricePerHour'] = pricePerHour;
    if (pricePerDay != null) json['pricePerDay'] = pricePerDay;
    if (instantBook != null) json['instantBook'] = instantBook;
    if (dailyKmLimit != null) json['dailyKmLimit'] = dailyKmLimit;
    if (excessKmPrice != null) json['excessKmPrice'] = excessKmPrice;
    if (weeklyDiscount != null) json['weeklyDiscount'] = weeklyDiscount;
    if (monthlyDiscount != null) json['monthlyDiscount'] = monthlyDiscount;
    if (allowSmoke != null) json['allowSmoke'] = allowSmoke;
    if (allowPets != null) json['allowPets'] = allowPets;
    if (geoRestriction != null) json['geoRestriction'] = geoRestriction;
    if (batteryReturnMin != null) json['batteryReturnMin'] = batteryReturnMin;
    if (address != null) json['address'] = address;
    if (latitude != null) json['latitude'] = latitude;
    if (longitude != null) json['longitude'] = longitude;
    if (description != null) json['description'] = description;
    if (images != null) json['images'] = images;
    for (final field in fieldsToClear) {
      json[field] = null;
    }

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
    address,
    latitude,
    longitude,
    description,
    images,
    fieldsToClear,
  ];
}
