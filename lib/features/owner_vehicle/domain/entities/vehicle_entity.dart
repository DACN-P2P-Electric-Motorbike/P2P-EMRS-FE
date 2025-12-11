import 'package:equatable/equatable.dart';

/// Vehicle status enum matching backend
enum VehicleStatus {
  available,
  rented,
  maintenance,
  pendingApproval,
  rejected,
  locked,
  unavailable;

  static VehicleStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'AVAILABLE':
        return VehicleStatus.available;
      case 'RENTED':
        return VehicleStatus.rented;
      case 'MAINTENANCE':
        return VehicleStatus.maintenance;
      case 'PENDING_APPROVAL':
        return VehicleStatus.pendingApproval;
      case 'REJECTED':
        return VehicleStatus.rejected;
      case 'LOCKED':
        return VehicleStatus.locked;
      case 'UNAVAILABLE':
        return VehicleStatus.unavailable;
      default:
        return VehicleStatus.pendingApproval;
    }
  }

  String toApiString() {
    switch (this) {
      case VehicleStatus.available:
        return 'AVAILABLE';
      case VehicleStatus.rented:
        return 'RENTED';
      case VehicleStatus.maintenance:
        return 'MAINTENANCE';
      case VehicleStatus.pendingApproval:
        return 'PENDING_APPROVAL';
      case VehicleStatus.rejected:
        return 'REJECTED';
      case VehicleStatus.locked:
        return 'LOCKED';
      case VehicleStatus.unavailable:
        return 'UNAVAILABLE';
    }
  }

  String get displayName {
    switch (this) {
      case VehicleStatus.available:
        return 'For rent';
      case VehicleStatus.rented:
        return 'Rented';
      case VehicleStatus.maintenance:
        return 'Maintenance';
      case VehicleStatus.pendingApproval:
        return 'Pending';
      case VehicleStatus.rejected:
        return 'Rejected';
      case VehicleStatus.locked:
        return 'Locked';
      case VehicleStatus.unavailable:
        return 'Unavailable';
    }
  }
}

/// Vehicle brand enum
enum VehicleBrand {
  vinfast,
  pega,
  yadea,
  other;

  static VehicleBrand fromString(String value) {
    switch (value.toUpperCase()) {
      case 'VINFAST':
        return VehicleBrand.vinfast;
      case 'PEGA':
        return VehicleBrand.pega;
      case 'YADEA':
        return VehicleBrand.yadea;
      default:
        return VehicleBrand.other;
    }
  }

  String toApiString() {
    switch (this) {
      case VehicleBrand.vinfast:
        return 'VINFAST';
      case VehicleBrand.pega:
        return 'PEGA';
      case VehicleBrand.yadea:
        return 'YADEA';
      case VehicleBrand.other:
        return 'OTHER';
    }
  }

  String get displayName {
    switch (this) {
      case VehicleBrand.vinfast:
        return 'VinFast';
      case VehicleBrand.pega:
        return 'Pega';
      case VehicleBrand.yadea:
        return 'Yadea';
      case VehicleBrand.other:
        return 'Other';
    }
  }
}

/// Vehicle type enum matching backend
enum VehicleType {
  vinfastKlara,
  vinfastFeliz,
  vinfastVento,
  electricScooter,
  electricMotorcycle,
  electricBike,
  other;

  static VehicleType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'VINFAST_KLARA':
        return VehicleType.vinfastKlara;
      case 'VINFAST_FELIZ':
        return VehicleType.vinfastFeliz;
      case 'VINFAST_VENTO':
        return VehicleType.vinfastVento;
      case 'ELECTRIC_SCOOTER':
        return VehicleType.electricScooter;
      case 'ELECTRIC_MOTORCYCLE':
        return VehicleType.electricMotorcycle;
      case 'ELECTRIC_BIKE':
        return VehicleType.electricBike;
      default:
        return VehicleType.other;
    }
  }

  String toApiString() {
    switch (this) {
      case VehicleType.vinfastKlara:
        return 'VINFAST_KLARA';
      case VehicleType.vinfastFeliz:
        return 'VINFAST_FELIZ';
      case VehicleType.vinfastVento:
        return 'VINFAST_VENTO';
      case VehicleType.electricScooter:
        return 'ELECTRIC_SCOOTER';
      case VehicleType.electricMotorcycle:
        return 'ELECTRIC_MOTORCYCLE';
      case VehicleType.electricBike:
        return 'ELECTRIC_BIKE';
      case VehicleType.other:
        return 'OTHER';
    }
  }

  String get displayName {
    switch (this) {
      case VehicleType.vinfastKlara:
        return 'VinFast Klara';
      case VehicleType.vinfastFeliz:
        return 'VinFast Feliz';
      case VehicleType.vinfastVento:
        return 'VinFast Vento';
      case VehicleType.electricScooter:
        return 'Electric Scooter';
      case VehicleType.electricMotorcycle:
        return 'Electric Motorcycle';
      case VehicleType.electricBike:
        return 'Electric Bike';
      case VehicleType.other:
        return 'Other';
    }
  }
}

/// Vehicle features enum
enum VehicleFeature {
  replaceableBattery,
  fastCharging,
  difficultTerrain,
  gpsTracking,
  antiTheft;

  static VehicleFeature fromString(String value) {
    switch (value.toUpperCase()) {
      case 'REPLACEABLE_BATTERY':
        return VehicleFeature.replaceableBattery;
      case 'FAST_CHARGING':
        return VehicleFeature.fastCharging;
      case 'DIFFICULT_TERRAIN':
        return VehicleFeature.difficultTerrain;
      case 'GPS_TRACKING':
        return VehicleFeature.gpsTracking;
      case 'ANTI_THEFT':
        return VehicleFeature.antiTheft;
      default:
        return VehicleFeature.replaceableBattery;
    }
  }

  String toApiString() {
    switch (this) {
      case VehicleFeature.replaceableBattery:
        return 'REPLACEABLE_BATTERY';
      case VehicleFeature.fastCharging:
        return 'FAST_CHARGING';
      case VehicleFeature.difficultTerrain:
        return 'DIFFICULT_TERRAIN';
      case VehicleFeature.gpsTracking:
        return 'GPS_TRACKING';
      case VehicleFeature.antiTheft:
        return 'ANTI_THEFT';
    }
  }

  String get displayName {
    switch (this) {
      case VehicleFeature.replaceableBattery:
        return 'Replaceable Battery';
      case VehicleFeature.fastCharging:
        return 'Fast Charging';
      case VehicleFeature.difficultTerrain:
        return 'Difficult Terrain Support';
      case VehicleFeature.gpsTracking:
        return 'GPS Tracking';
      case VehicleFeature.antiTheft:
        return 'Anti-theft System';
    }
  }
}

/// Vehicle entity representing the domain model
class VehicleEntity extends Equatable {
  final String id;
  final String? name;
  final String licensePlate;
  final String model;
  final VehicleBrand brand;
  final VehicleType type;
  final int? year;
  final VehicleStatus status;
  final List<VehicleFeature> features;
  final double? batteryCapacity; // kWh
  final int batteryLevel;
  final double? maxSpeed; // km/h
  final double? range; // km per charge
  final double pricePerHour;
  final double? pricePerDay;
  final double? deposit;
  final bool isAvailable;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? description;
  final List<String> images;
  final String? licenseNumber;
  final String? licenseFront;
  final String? licenseBack;
  final int totalTrips;
  final double totalRating;
  final int reviewCount;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VehicleEntity({
    required this.id,
    this.name,
    required this.licensePlate,
    required this.model,
    required this.brand,
    required this.type,
    this.year,
    required this.status,
    this.features = const [],
    this.batteryCapacity,
    required this.batteryLevel,
    this.maxSpeed,
    this.range,
    required this.pricePerHour,
    this.pricePerDay,
    this.deposit,
    this.isAvailable = true,
    required this.address,
    this.latitude,
    this.longitude,
    this.description,
    required this.images,
    this.licenseNumber,
    this.licenseFront,
    this.licenseBack,
    required this.totalTrips,
    required this.totalRating,
    this.reviewCount = 0,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get display name (name or model)
  String get displayName => name ?? model;

  /// Get first image or placeholder
  String get thumbnailUrl =>
      images.isNotEmpty ? images.first : 'https://via.placeholder.com/150';

  /// Format price for display (per day)
  String get formattedPricePerDay {
    final price = pricePerDay ?? (pricePerHour * 24);
    return '${_formatNumber(price)}đ/day';
  }

  /// Format price for display (per hour)
  String get formattedPricePerHour =>
      '${_formatNumber(pricePerHour)}đ/h';

  /// Helper to format number with commas
  String _formatNumber(num number) {
    return number.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  /// Check if vehicle can be edited by owner
  bool get canEditStatus =>
      status != VehicleStatus.pendingApproval &&
      status != VehicleStatus.rejected &&
      status != VehicleStatus.locked &&
      status != VehicleStatus.rented;

  @override
  List<Object?> get props => [
        id,
        name,
        licensePlate,
        model,
        brand,
        type,
        year,
        status,
        features,
        batteryCapacity,
        batteryLevel,
        maxSpeed,
        range,
        pricePerHour,
        pricePerDay,
        deposit,
        isAvailable,
        address,
        latitude,
        longitude,
        description,
        images,
        licenseNumber,
        licenseFront,
        licenseBack,
        totalTrips,
        totalRating,
        reviewCount,
        ownerId,
        createdAt,
        updatedAt,
      ];
}
