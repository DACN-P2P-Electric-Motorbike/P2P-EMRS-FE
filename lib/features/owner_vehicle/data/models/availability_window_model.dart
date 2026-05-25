import 'package:equatable/equatable.dart';

import '../../domain/entities/vehicle_entity.dart';

class CreateAvailabilityWindowParams extends Equatable {
  final AvailabilityWindowType type;
  final AvailabilityWindowRecurrence recurrence;
  final List<int> recurringWeekdays;
  final int? timezoneOffsetMinutes;
  final DateTime? recurrenceEndsAt;
  final DateTime startTime;
  final DateTime endTime;
  final String? note;

  const CreateAvailabilityWindowParams({
    required this.type,
    this.recurrence = AvailabilityWindowRecurrence.once,
    this.recurringWeekdays = const [],
    this.timezoneOffsetMinutes,
    this.recurrenceEndsAt,
    required this.startTime,
    required this.endTime,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toApiString(),
      'recurrence': recurrence.toApiString(),
      if (recurrence == AvailabilityWindowRecurrence.weekly) ...{
        'recurringWeekdays': recurringWeekdays,
        'timezoneOffsetMinutes': timezoneOffsetMinutes,
        if (recurrenceEndsAt != null)
          'recurrenceEndsAt': recurrenceEndsAt!.toUtc().toIso8601String(),
      },
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime.toUtc().toIso8601String(),
      if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
    };
  }

  @override
  List<Object?> get props => [
    type,
    recurrence,
    recurringWeekdays,
    timezoneOffsetMinutes,
    recurrenceEndsAt,
    startTime,
    endTime,
    note,
  ];
}

class VehicleAvailabilityWindowModel extends VehicleAvailabilityWindowEntity {
  const VehicleAvailabilityWindowModel({
    required super.id,
    required super.vehicleId,
    required super.type,
    super.recurrence,
    super.recurringWeekdays,
    super.timezoneOffsetMinutes,
    super.recurrenceEndsAt,
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
      recurrence: AvailabilityWindowRecurrence.fromString(
        json['recurrence'] as String? ?? 'ONCE',
      ),
      recurringWeekdays: (json['recurringWeekdays'] as List<dynamic>? ?? [])
          .map((day) => (day as num).toInt())
          .toList(),
      timezoneOffsetMinutes: (json['timezoneOffsetMinutes'] as num?)?.toInt(),
      recurrenceEndsAt: json['recurrenceEndsAt'] == null
          ? null
          : DateTime.parse(json['recurrenceEndsAt'] as String).toLocal(),
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
      'recurrence': recurrence.toApiString(),
      'recurringWeekdays': recurringWeekdays,
      'timezoneOffsetMinutes': timezoneOffsetMinutes,
      'recurrenceEndsAt': recurrenceEndsAt?.toUtc().toIso8601String(),
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
      recurrence: recurrence,
      recurringWeekdays: recurringWeekdays,
      timezoneOffsetMinutes: timezoneOffsetMinutes,
      recurrenceEndsAt: recurrenceEndsAt,
      startTime: startTime,
      endTime: endTime,
      note: note,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
