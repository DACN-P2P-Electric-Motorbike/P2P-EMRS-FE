import 'package:equatable/equatable.dart';

enum HandoverType { checkIn, checkOut }

class HandoverPhoto extends Equatable {
  final String id;
  final String handoverId;
  final String photoUrl;
  final String photoType;
  final double? latitude;
  final double? longitude;
  final DateTime capturedAt;
  final DateTime createdAt;

  const HandoverPhoto({
    required this.id,
    required this.handoverId,
    required this.photoUrl,
    required this.photoType,
    this.latitude,
    this.longitude,
    required this.capturedAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    handoverId,
    photoUrl,
    photoType,
    latitude,
    longitude,
    capturedAt,
    createdAt,
  ];
}

class VehicleHandover extends Equatable {
  final String id;
  final String bookingId;
  final String? tripId;
  final HandoverType type;
  final String performedBy;
  final double? odometerReading;
  final int? batteryLevel;
  final double? latitude;
  final double? longitude;
  final String? notes;
  final bool confirmedByOwner;
  final bool confirmedByRenter;
  final List<HandoverPhoto> photos;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VehicleHandover({
    required this.id,
    required this.bookingId,
    this.tripId,
    required this.type,
    required this.performedBy,
    this.odometerReading,
    this.batteryLevel,
    this.latitude,
    this.longitude,
    this.notes,
    required this.confirmedByOwner,
    required this.confirmedByRenter,
    required this.photos,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isComplete => confirmedByOwner && confirmedByRenter;

  @override
  List<Object?> get props => [
    id,
    bookingId,
    tripId,
    type,
    performedBy,
    odometerReading,
    batteryLevel,
    latitude,
    longitude,
    notes,
    confirmedByOwner,
    confirmedByRenter,
    photos,
    createdAt,
    updatedAt,
  ];
}

class HandoverDifferences extends Equatable {
  final double? kmDriven;
  final int? batteryDelta;

  const HandoverDifferences({this.kmDriven, this.batteryDelta});

  @override
  List<Object?> get props => [kmDriven, batteryDelta];
}

class HandoverSummary extends Equatable {
  final String bookingId;
  final VehicleHandover? checkIn;
  final VehicleHandover? checkOut;
  final HandoverDifferences differences;

  const HandoverSummary({
    required this.bookingId,
    this.checkIn,
    this.checkOut,
    required this.differences,
  });

  @override
  List<Object?> get props => [bookingId, checkIn, checkOut, differences];
}

class HandoverPhotoInput extends Equatable {
  final String photoUrl;
  final String photoType;
  final double? latitude;
  final double? longitude;
  final DateTime? capturedAt;

  const HandoverPhotoInput({
    required this.photoUrl,
    required this.photoType,
    this.latitude,
    this.longitude,
    this.capturedAt,
  });

  Map<String, dynamic> toJson() => {
    'photoUrl': photoUrl,
    'photoType': photoType,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    if (capturedAt != null) 'capturedAt': capturedAt!.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    photoUrl,
    photoType,
    latitude,
    longitude,
    capturedAt,
  ];
}
