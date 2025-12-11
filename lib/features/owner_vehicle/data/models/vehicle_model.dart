import '../../domain/entities/vehicle_entity.dart';

/// Vehicle data model for API serialization
class VehicleModel extends VehicleEntity {
  const VehicleModel({
    required super.id,
    super.name,
    required super.licensePlate,
    required super.model,
    required super.brand,
    required super.type,
    super.year,
    required super.status,
    super.features = const [],
    super.batteryCapacity,
    required super.batteryLevel,
    super.maxSpeed,
    super.range,
    required super.pricePerHour,
    super.pricePerDay,
    super.deposit,
    super.isAvailable = true,
    required super.address,
    super.latitude,
    super.longitude,
    super.description,
    required super.images,
    super.licenseNumber,
    super.licenseFront,
    super.licenseBack,
    required super.totalTrips,
    required super.totalRating,
    super.reviewCount = 0,
    required super.ownerId,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create VehicleModel from JSON response
  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      licensePlate: json['licensePlate'] as String,
      model: json['model'] as String,
      brand: VehicleBrand.fromString(json['brand'] as String? ?? 'OTHER'),
      type: VehicleType.fromString(json['type'] as String),
      year: json['year'] as int?,
      status: VehicleStatus.fromString(json['status'] as String),
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => VehicleFeature.fromString(e as String))
              .toList() ??
          [],
      batteryCapacity: json['batteryCapacity'] != null
          ? (json['batteryCapacity'] as num).toDouble()
          : null,
      batteryLevel: json['batteryLevel'] as int? ?? 100,
      maxSpeed: json['maxSpeed'] != null
          ? (json['maxSpeed'] as num).toDouble()
          : null,
      range: json['range'] != null
          ? (json['range'] as num).toDouble()
          : null,
      pricePerHour: _parsePrice(json['pricePerHour']),
      pricePerDay: json['pricePerDay'] != null
          ? _parsePrice(json['pricePerDay'])
          : null,
      deposit: json['deposit'] != null
          ? (json['deposit'] as num).toDouble()
          : null,
      isAvailable: json['isAvailable'] as bool? ?? true,
      address: json['address'] as String,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      description: json['description'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      licenseNumber: json['licenseNumber'] as String?,
      licenseFront: json['licenseFront'] as String?,
      licenseBack: json['licenseBack'] as String?,
      totalTrips: json['totalTrips'] as int? ?? 0,
      totalRating: (json['totalRating'] as num?)?.toDouble() ?? 5.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      ownerId: json['ownerId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Helper to parse price which might come as string or number
  static double _parsePrice(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Convert to JSON (for debugging/logging)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'licensePlate': licensePlate,
      'model': model,
      'brand': brand.toApiString(),
      'type': type.toApiString(),
      'year': year,
      'status': status.toApiString(),
      'features': features.map((f) => f.toApiString()).toList(),
      'batteryCapacity': batteryCapacity,
      'batteryLevel': batteryLevel,
      'maxSpeed': maxSpeed,
      'range': range,
      'pricePerHour': pricePerHour,
      'pricePerDay': pricePerDay,
      'deposit': deposit,
      'isAvailable': isAvailable,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'images': images,
      'licenseNumber': licenseNumber,
      'licenseFront': licenseFront,
      'licenseBack': licenseBack,
      'totalTrips': totalTrips,
      'totalRating': totalRating,
      'reviewCount': reviewCount,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert to VehicleEntity
  VehicleEntity toEntity() {
    return VehicleEntity(
      id: id,
      name: name,
      licensePlate: licensePlate,
      model: model,
      brand: brand,
      type: type,
      year: year,
      status: status,
      features: features,
      batteryCapacity: batteryCapacity,
      batteryLevel: batteryLevel,
      maxSpeed: maxSpeed,
      range: range,
      pricePerHour: pricePerHour,
      pricePerDay: pricePerDay,
      deposit: deposit,
      isAvailable: isAvailable,
      address: address,
      latitude: latitude,
      longitude: longitude,
      description: description,
      images: images,
      licenseNumber: licenseNumber,
      licenseFront: licenseFront,
      licenseBack: licenseBack,
      totalTrips: totalTrips,
      totalRating: totalRating,
      reviewCount: reviewCount,
      ownerId: ownerId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
