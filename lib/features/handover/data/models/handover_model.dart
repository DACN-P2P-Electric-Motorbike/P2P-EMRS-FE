import '../../domain/entities/handover.dart';

class HandoverPhotoModel extends HandoverPhoto {
  const HandoverPhotoModel({
    required super.id,
    required super.handoverId,
    required super.photoUrl,
    required super.photoType,
    super.latitude,
    super.longitude,
    required super.capturedAt,
    required super.createdAt,
  });

  factory HandoverPhotoModel.fromJson(Map<String, dynamic> json) {
    return HandoverPhotoModel(
      id: json['id'] as String,
      handoverId: json['handoverId'] as String,
      photoUrl: json['photoUrl'] as String,
      photoType: json['photoType'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      capturedAt: DateTime.parse(json['capturedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  HandoverPhoto toEntity() => HandoverPhoto(
    id: id,
    handoverId: handoverId,
    photoUrl: photoUrl,
    photoType: photoType,
    latitude: latitude,
    longitude: longitude,
    capturedAt: capturedAt,
    createdAt: createdAt,
  );
}

class VehicleHandoverModel extends VehicleHandover {
  const VehicleHandoverModel({
    required super.id,
    required super.bookingId,
    super.tripId,
    required super.type,
    required super.performedBy,
    super.odometerReading,
    super.batteryLevel,
    super.fuelLevel,
    super.latitude,
    super.longitude,
    super.notes,
    required super.confirmedByOwner,
    required super.confirmedByRenter,
    required super.photos,
    required super.createdAt,
    required super.updatedAt,
  });

  factory VehicleHandoverModel.fromJson(Map<String, dynamic> json) {
    final photos = (json['photos'] as List<dynamic>? ?? [])
        .map(
          (item) => HandoverPhotoModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    return VehicleHandoverModel(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      tripId: json['tripId'] as String?,
      type: _typeFromString(json['type'] as String?),
      performedBy: json['performedBy'] as String,
      odometerReading: (json['odometerReading'] as num?)?.toDouble(),
      batteryLevel: (json['batteryLevel'] as num?)?.toInt(),
      fuelLevel: (json['fuelLevel'] as num?)?.toInt(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      confirmedByOwner: json['confirmedByOwner'] as bool? ?? false,
      confirmedByRenter: json['confirmedByRenter'] as bool? ?? false,
      photos: photos.map((item) => item.toEntity()).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  VehicleHandover toEntity() => VehicleHandover(
    id: id,
    bookingId: bookingId,
    tripId: tripId,
    type: type,
    performedBy: performedBy,
    odometerReading: odometerReading,
    batteryLevel: batteryLevel,
    fuelLevel: fuelLevel,
    latitude: latitude,
    longitude: longitude,
    notes: notes,
    confirmedByOwner: confirmedByOwner,
    confirmedByRenter: confirmedByRenter,
    photos: photos,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  static HandoverType _typeFromString(String? value) {
    switch ((value ?? '').toUpperCase()) {
      case 'CHECK_OUT':
        return HandoverType.checkOut;
      case 'CHECK_IN':
      default:
        return HandoverType.checkIn;
    }
  }
}

class HandoverDifferencesModel extends HandoverDifferences {
  const HandoverDifferencesModel({
    super.kmDriven,
    super.batteryDelta,
    super.fuelDelta,
  });

  factory HandoverDifferencesModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const HandoverDifferencesModel();
    return HandoverDifferencesModel(
      kmDriven: (json['kmDriven'] as num?)?.toDouble(),
      batteryDelta: (json['batteryDelta'] as num?)?.toInt(),
      fuelDelta: (json['fuelDelta'] as num?)?.toInt(),
    );
  }

  HandoverDifferences toEntity() => HandoverDifferences(
    kmDriven: kmDriven,
    batteryDelta: batteryDelta,
    fuelDelta: fuelDelta,
  );
}

class HandoverSummaryModel extends HandoverSummary {
  const HandoverSummaryModel({
    required super.bookingId,
    super.checkIn,
    super.checkOut,
    required super.differences,
  });

  factory HandoverSummaryModel.fromJson(Map<String, dynamic> json) {
    final checkInJson = json['checkIn'] as Map<String, dynamic>?;
    final checkOutJson = json['checkOut'] as Map<String, dynamic>?;
    final differencesModel = HandoverDifferencesModel.fromJson(
      json['differences'] as Map<String, dynamic>?,
    );

    return HandoverSummaryModel(
      bookingId: json['bookingId'] as String,
      checkIn: checkInJson == null
          ? null
          : VehicleHandoverModel.fromJson(checkInJson).toEntity(),
      checkOut: checkOutJson == null
          ? null
          : VehicleHandoverModel.fromJson(checkOutJson).toEntity(),
      differences: differencesModel.toEntity(),
    );
  }

  HandoverSummary toEntity() => HandoverSummary(
    bookingId: bookingId,
    checkIn: checkIn,
    checkOut: checkOut,
    differences: differences,
  );
}
