import '../../domain/entities/trip_entity.dart';

class TripModel extends TripEntity {
  const TripModel({
    required super.id,
    required super.bookingId,
    required super.renterId,
    required super.vehicleId,
    required super.status,
    super.startLatitude,
    super.startLongitude,
    super.startAddress,
    super.endLatitude,
    super.endLongitude,
    super.endAddress,
    super.distanceTraveled,
    super.duration,
    super.startBattery,
    super.endBattery,
    required super.hasIssues,
    super.issueDescription,
    super.startedAt,
    super.completedAt,
    required super.createdAt,
    required super.updatedAt,
    super.vehicleName,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    TripStatus parseStatus(String? value) {
      switch ((value ?? '').toUpperCase()) {
        case 'ONGOING':
          return TripStatus.ongoing;
        case 'COMPLETED':
          return TripStatus.completed;
        case 'CANCELLED':
          return TripStatus.cancelled;
        default:
          return TripStatus.notStarted;
      }
    }

    // Extract vehicle name from nested booking→vehicle relation (history endpoint)
    final booking = json['booking'] as Map<String, dynamic>?;
    final vehicle = booking?['vehicle'] as Map<String, dynamic>?;
    final vehicleName = vehicle?['name'] as String?;

    return TripModel(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      renterId: json['renterId'] as String,
      vehicleId: json['vehicleId'] as String,
      status: parseStatus(json['status'] as String?),
      startLatitude: (json['startLatitude'] as num?)?.toDouble(),
      startLongitude: (json['startLongitude'] as num?)?.toDouble(),
      startAddress: json['startAddress'] as String?,
      endLatitude: (json['endLatitude'] as num?)?.toDouble(),
      endLongitude: (json['endLongitude'] as num?)?.toDouble(),
      endAddress: json['endAddress'] as String?,
      distanceTraveled: (json['distanceTraveled'] as num?)?.toDouble(),
      duration: json['duration'] as int?,
      startBattery: (json['startBattery'] as num?)?.toDouble(),
      endBattery: (json['endBattery'] as num?)?.toDouble(),
      hasIssues: json['hasIssues'] as bool? ?? false,
      issueDescription: json['issueDescription'] as String?,
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      vehicleName: vehicleName,
    );
  }

  TripEntity toEntity() => TripEntity(
    id: id,
    bookingId: bookingId,
    renterId: renterId,
    vehicleId: vehicleId,
    status: status,
    startLatitude: startLatitude,
    startLongitude: startLongitude,
    startAddress: startAddress,
    endLatitude: endLatitude,
    endLongitude: endLongitude,
    endAddress: endAddress,
    distanceTraveled: distanceTraveled,
    duration: duration,
    startBattery: startBattery,
    endBattery: endBattery,
    hasIssues: hasIssues,
    issueDescription: issueDescription,
    startedAt: startedAt,
    completedAt: completedAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
    vehicleName: vehicleName,
  );
}
