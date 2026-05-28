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
        return 'Đang cho thuê';
      case VehicleStatus.rented:
        return 'Đang thuê';
      case VehicleStatus.maintenance:
        return 'Bảo trì';
      case VehicleStatus.pendingApproval:
        return 'Chờ duyệt';
      case VehicleStatus.rejected:
        return 'Từ chối';
      case VehicleStatus.locked:
        return 'Đã khóa';
      case VehicleStatus.unavailable:
        return 'Tạm tắt';
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
        return 'Khác';
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
        return 'Xe tay ga điện';
      case VehicleType.electricMotorcycle:
        return 'Xe máy điện';
      case VehicleType.electricBike:
        return 'Xe đạp điện';
      case VehicleType.other:
        return 'Khác';
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
        return 'Pin tháo rời';
      case VehicleFeature.fastCharging:
        return 'Sạc nhanh';
      case VehicleFeature.difficultTerrain:
        return 'Đi địa hình';
      case VehicleFeature.gpsTracking:
        return 'Định vị GPS';
      case VehicleFeature.antiTheft:
        return 'Chống trộm';
    }
  }
}

/// Vehicle condition enum matching backend
enum VehicleCondition {
  newVehicle,
  likeNew,
  good,
  fair,
  needsMaintenance;

  static VehicleCondition? fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'NEW':
        return VehicleCondition.newVehicle;
      case 'LIKE_NEW':
        return VehicleCondition.likeNew;
      case 'GOOD':
        return VehicleCondition.good;
      case 'FAIR':
        return VehicleCondition.fair;
      case 'NEEDS_MAINTENANCE':
        return VehicleCondition.needsMaintenance;
      default:
        return null;
    }
  }

  String toApiString() {
    switch (this) {
      case VehicleCondition.newVehicle:
        return 'NEW';
      case VehicleCondition.likeNew:
        return 'LIKE_NEW';
      case VehicleCondition.good:
        return 'GOOD';
      case VehicleCondition.fair:
        return 'FAIR';
      case VehicleCondition.needsMaintenance:
        return 'NEEDS_MAINTENANCE';
    }
  }

  String get displayName {
    switch (this) {
      case VehicleCondition.newVehicle:
        return 'Xe mới';
      case VehicleCondition.likeNew:
        return 'Như mới';
      case VehicleCondition.good:
        return 'Tốt';
      case VehicleCondition.fair:
        return 'Khá';
      case VehicleCondition.needsMaintenance:
        return 'Cần bảo trì';
    }
  }
}

/// EV battery pack type
enum BatteryType {
  fixedNonRemovable,
  removable,
  swappable;

  static BatteryType? fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'FIXED_NON_REMOVABLE':
        return BatteryType.fixedNonRemovable;
      case 'REMOVABLE':
        return BatteryType.removable;
      case 'SWAPPABLE':
        return BatteryType.swappable;
      default:
        return null;
    }
  }

  String toApiString() {
    switch (this) {
      case BatteryType.fixedNonRemovable:
        return 'FIXED_NON_REMOVABLE';
      case BatteryType.removable:
        return 'REMOVABLE';
      case BatteryType.swappable:
        return 'SWAPPABLE';
    }
  }

  String get displayName {
    switch (this) {
      case BatteryType.fixedNonRemovable:
        return 'Pin liền xe';
      case BatteryType.removable:
        return 'Pin tháo rời';
      case BatteryType.swappable:
        return 'Pin có thể đổi';
    }
  }
}

enum CancellationPolicy {
  flexible,
  moderate,
  strict;

  static CancellationPolicy fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'MODERATE':
        return CancellationPolicy.moderate;
      case 'STRICT':
        return CancellationPolicy.strict;
      case 'FLEXIBLE':
      default:
        return CancellationPolicy.flexible;
    }
  }

  String toApiString() {
    switch (this) {
      case CancellationPolicy.flexible:
        return 'FLEXIBLE';
      case CancellationPolicy.moderate:
        return 'MODERATE';
      case CancellationPolicy.strict:
        return 'STRICT';
    }
  }

  String get displayName {
    switch (this) {
      case CancellationPolicy.flexible:
        return 'Linh hoạt';
      case CancellationPolicy.moderate:
        return 'Trung bình';
      case CancellationPolicy.strict:
        return 'Nghiêm ngặt';
    }
  }

  String get summaryText {
    switch (this) {
      case CancellationPolicy.flexible:
        return 'Hoàn 100% trước 24 giờ, sau đó hoàn 50%';
      case CancellationPolicy.moderate:
        return 'Hoàn 100% trước 5 ngày, sau đó hoàn 50%';
      case CancellationPolicy.strict:
        return 'Hoàn 50% trước 7 ngày, sau đó không hoàn phí thuê';
    }
  }
}

/// Availability calendar window type
enum AvailabilityWindowType {
  available,
  blocked;

  static AvailabilityWindowType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'BLOCKED':
        return AvailabilityWindowType.blocked;
      case 'AVAILABLE':
      default:
        return AvailabilityWindowType.available;
    }
  }

  String toApiString() {
    switch (this) {
      case AvailabilityWindowType.available:
        return 'AVAILABLE';
      case AvailabilityWindowType.blocked:
        return 'BLOCKED';
    }
  }

  String get displayName {
    switch (this) {
      case AvailabilityWindowType.available:
        return 'Có thể cho thuê';
      case AvailabilityWindowType.blocked:
        return 'Chặn lịch';
    }
  }
}

enum AvailabilityWindowRecurrence {
  once,
  weekly;

  static AvailabilityWindowRecurrence fromString(String value) {
    return value.toUpperCase() == 'WEEKLY'
        ? AvailabilityWindowRecurrence.weekly
        : AvailabilityWindowRecurrence.once;
  }

  String toApiString() {
    return this == AvailabilityWindowRecurrence.weekly ? 'WEEKLY' : 'ONCE';
  }

  String get displayName {
    return this == AvailabilityWindowRecurrence.weekly
        ? 'Hàng tuần'
        : 'Một lần';
  }
}

/// Owner-managed vehicle availability window
class VehicleAvailabilityWindowEntity extends Equatable {
  final String id;
  final String vehicleId;
  final AvailabilityWindowType type;
  final AvailabilityWindowRecurrence recurrence;
  final List<int> recurringWeekdays;
  final int? timezoneOffsetMinutes;
  final String? timezoneName;
  final DateTime? recurrenceEndsAt;
  final DateTime startTime;
  final DateTime endTime;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VehicleAvailabilityWindowEntity({
    required this.id,
    required this.vehicleId,
    required this.type,
    this.recurrence = AvailabilityWindowRecurrence.once,
    this.recurringWeekdays = const [],
    this.timezoneOffsetMinutes,
    this.timezoneName,
    this.recurrenceEndsAt,
    required this.startTime,
    required this.endTime,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isAvailableWindow => type == AvailabilityWindowType.available;
  bool get isWeekly => recurrence == AvailabilityWindowRecurrence.weekly;

  @override
  List<Object?> get props => [
    id,
    vehicleId,
    type,
    recurrence,
    recurringWeekdays,
    timezoneOffsetMinutes,
    timezoneName,
    recurrenceEndsAt,
    startTime,
    endTime,
    note,
    createdAt,
    updatedAt,
  ];
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
  final bool instantBook;
  final CancellationPolicy cancellationPolicy;
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
    this.instantBook = false,
    this.cancellationPolicy = CancellationPolicy.flexible,
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

  double get displayRating => reviewCount > 0 ? totalRating : 0;

  String get formattedRating => reviewCount > 0 ? totalRating.toStringAsFixed(1) : '—';

  /// Get display name (name or model)
  String get displayName => name ?? model;

  /// Get first image or placeholder
  String get thumbnailUrl =>
      images.isNotEmpty ? images.first : 'https://via.placeholder.com/150';

  /// Format price for display (per day)
  String get formattedPricePerDay {
    final price = pricePerDay ?? (pricePerHour * 24);
    return '${_formatNumber(price)}đ/ngày';
  }

  /// Format price for display (per hour)
  String get formattedPricePerHour => '${_formatNumber(pricePerHour)}đ/h';

  /// Helper to format number with commas
  String _formatNumber(num number) {
    return number
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
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
    instantBook,
    cancellationPolicy,
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
