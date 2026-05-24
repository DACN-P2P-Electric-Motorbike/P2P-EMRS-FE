import 'package:equatable/equatable.dart';

import '../../domain/entities/vehicle_entity.dart';

class CreateAvailabilityWindowParams extends Equatable {
  final AvailabilityWindowType type;
  final DateTime startTime;
  final DateTime endTime;
  final String? note;

  const CreateAvailabilityWindowParams({
    required this.type,
    required this.startTime,
    required this.endTime,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toApiString(),
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime.toUtc().toIso8601String(),
      if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
    };
  }

  @override
  List<Object?> get props => [type, startTime, endTime, note];
}

class VehicleAvailabilityWindowModel extends VehicleAvailabilityWindowEntity {
  const VehicleAvailabilityWindowModel({
    required super.id,
    required super.vehicleId,
    required super.type,
    required super.startTime,
    required super.endTime,
    super.note,
    required super.createdAt,
    required super.updatedAt,
  });

  factory VehicleAvailabilityWindowModel.fromJson(Map<String, dynamic> json) {
    return VehicleAvailabilityWindowModel(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
      type: AvailabilityWindowType.fromString(json['type'] as String),
      startTime: DateTime.parse(json['startTime'] as String).toLocal(),
      endTime: DateTime.parse(json['endTime'] as String).toLocal(),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'type': type.toApiString(),
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime.toUtc().toIso8601String(),
      'note': note,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }

  VehicleAvailabilityWindowEntity toEntity() {
    return VehicleAvailabilityWindowEntity(
      id: id,
      vehicleId: vehicleId,
      type: type,
      startTime: startTime,
      endTime: endTime,
      note: note,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
