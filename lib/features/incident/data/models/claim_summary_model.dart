import '../../domain/entities/claim_summary.dart';
import 'incident_report_model.dart';

class ClaimSummaryTotalsModel {
  final int incidentCount;
  final int openIncidentCount;
  final int unresolvedIncidentCount;
  final double pendingChargeAmount;
  final double approvedChargeAmount;
  final double capturedChargeAmount;
  final double finalizedChargeAmount;
  final double heldDepositAmount;
  final double releasableDepositAmount;
  final double ownerPayoutAmount;

  const ClaimSummaryTotalsModel({
    required this.incidentCount,
    required this.openIncidentCount,
    required this.unresolvedIncidentCount,
    required this.pendingChargeAmount,
    required this.approvedChargeAmount,
    required this.capturedChargeAmount,
    required this.finalizedChargeAmount,
    required this.heldDepositAmount,
    required this.releasableDepositAmount,
    required this.ownerPayoutAmount,
  });

  factory ClaimSummaryTotalsModel.fromJson(Map<String, dynamic> json) {
    return ClaimSummaryTotalsModel(
      incidentCount: _asInt(json['incidentCount']),
      openIncidentCount: _asInt(json['openIncidentCount']),
      unresolvedIncidentCount: _asInt(json['unresolvedIncidentCount']),
      pendingChargeAmount: _asDouble(json['pendingChargeAmount']),
      approvedChargeAmount: _asDouble(json['approvedChargeAmount']),
      capturedChargeAmount: _asDouble(json['capturedChargeAmount']),
      finalizedChargeAmount: _asDouble(json['finalizedChargeAmount']),
      heldDepositAmount: _asDouble(json['heldDepositAmount']),
      releasableDepositAmount: _asDouble(json['releasableDepositAmount']),
      ownerPayoutAmount: _asDouble(json['ownerPayoutAmount']),
    );
  }

  ClaimSummaryTotalsEntity toEntity() {
    return ClaimSummaryTotalsEntity(
      incidentCount: incidentCount,
      openIncidentCount: openIncidentCount,
      unresolvedIncidentCount: unresolvedIncidentCount,
      pendingChargeAmount: pendingChargeAmount,
      approvedChargeAmount: approvedChargeAmount,
      capturedChargeAmount: capturedChargeAmount,
      finalizedChargeAmount: finalizedChargeAmount,
      heldDepositAmount: heldDepositAmount,
      releasableDepositAmount: releasableDepositAmount,
      ownerPayoutAmount: ownerPayoutAmount,
    );
  }
}

class ClaimBlockerModel {
  final String code;
  final String label;
  final int count;
  final bool blocksDepositRelease;
  final bool blocksOwnerPayout;

  const ClaimBlockerModel({
    required this.code,
    required this.label,
    required this.count,
    required this.blocksDepositRelease,
    required this.blocksOwnerPayout,
  });

  factory ClaimBlockerModel.fromJson(Map<String, dynamic> json) {
    return ClaimBlockerModel(
      code: json['code'] as String? ?? '',
      label: json['label'] as String? ?? '',
      count: _asInt(json['count']),
      blocksDepositRelease: json['blocksDepositRelease'] == true,
      blocksOwnerPayout: json['blocksOwnerPayout'] == true,
    );
  }

  ClaimBlockerEntity toEntity() {
    return ClaimBlockerEntity(
      code: code,
      label: label,
      count: count,
      blocksDepositRelease: blocksDepositRelease,
      blocksOwnerPayout: blocksOwnerPayout,
    );
  }
}

class ClaimNextActionModel {
  final String actor;
  final String action;
  final String reason;
  final String priority;

  const ClaimNextActionModel({
    required this.actor,
    required this.action,
    required this.reason,
    required this.priority,
  });

  factory ClaimNextActionModel.fromJson(Map<String, dynamic> json) {
    return ClaimNextActionModel(
      actor: json['actor'] as String? ?? '',
      action: json['action'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      priority: json['priority'] as String? ?? 'LOW',
    );
  }

  ClaimNextActionEntity toEntity() {
    return ClaimNextActionEntity(
      actor: actor,
      action: action,
      reason: reason,
      priority: priority,
    );
  }
}

class ClaimTimelineEventModel {
  final String type;
  final String label;
  final String? status;
  final double? amount;
  final DateTime occurredAt;
  final String? sourceId;
  final String? actorId;

  const ClaimTimelineEventModel({
    required this.type,
    required this.label,
    this.status,
    this.amount,
    required this.occurredAt,
    this.sourceId,
    this.actorId,
  });

  factory ClaimTimelineEventModel.fromJson(Map<String, dynamic> json) {
    return ClaimTimelineEventModel(
      type: json['type'] as String? ?? '',
      label: json['label'] as String? ?? '',
      status: json['status'] as String?,
      amount: _asNullableDouble(json['amount']),
      occurredAt: _parseRequiredDate(json['occurredAt']),
      sourceId: json['sourceId'] as String?,
      actorId: json['actorId'] as String?,
    );
  }

  ClaimTimelineEventEntity toEntity() {
    return ClaimTimelineEventEntity(
      type: type,
      label: label,
      status: status,
      amount: amount,
      occurredAt: occurredAt,
      sourceId: sourceId,
      actorId: actorId,
    );
  }
}

class BookingClaimSummaryModel {
  final String bookingId;
  final String status;
  final String statusLabel;
  final ClaimSummaryTotalsModel totals;
  final List<ClaimBlockerModel> blockers;
  final List<ClaimNextActionModel> nextActions;
  final List<ClaimTimelineEventModel> timeline;
  final List<IncidentReportModel> incidents;
  final bool canReleaseDeposit;
  final bool canProcessPayout;

  const BookingClaimSummaryModel({
    required this.bookingId,
    required this.status,
    required this.statusLabel,
    required this.totals,
    required this.blockers,
    required this.nextActions,
    required this.timeline,
    required this.incidents,
    required this.canReleaseDeposit,
    required this.canProcessPayout,
  });

  factory BookingClaimSummaryModel.fromJson(Map<String, dynamic> json) {
    return BookingClaimSummaryModel(
      bookingId: json['bookingId'] as String? ?? '',
      status: json['status'] as String? ?? 'NO_CLAIM',
      statusLabel: json['statusLabel'] as String? ?? '',
      totals: ClaimSummaryTotalsModel.fromJson(_asMap(json['totals'])),
      blockers: _mapList(
        json['blockers'],
        (item) => ClaimBlockerModel.fromJson(item),
      ),
      nextActions: _mapList(
        json['nextActions'],
        (item) => ClaimNextActionModel.fromJson(item),
      ),
      timeline: _mapList(
        json['timeline'],
        (item) => ClaimTimelineEventModel.fromJson(item),
      ),
      incidents: _mapList(
        json['incidents'],
        (item) => IncidentReportModel.fromJson(item),
      ),
      canReleaseDeposit: json['canReleaseDeposit'] == true,
      canProcessPayout: json['canProcessPayout'] == true,
    );
  }

  BookingClaimSummaryEntity toEntity() {
    return BookingClaimSummaryEntity(
      bookingId: bookingId,
      status: ClaimWorkflowStatus.fromString(status),
      statusLabel: statusLabel,
      totals: totals.toEntity(),
      blockers: blockers.map((item) => item.toEntity()).toList(),
      nextActions: nextActions.map((item) => item.toEntity()).toList(),
      timeline: timeline.map((item) => item.toEntity()).toList(),
      incidents: incidents.map((item) => item.toEntity()).toList(),
      canReleaseDeposit: canReleaseDeposit,
      canProcessPayout: canProcessPayout,
    );
  }
}

List<T> _mapList<T>(
  dynamic value,
  T Function(Map<String, dynamic> item) mapper,
) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => mapper(Map<String, dynamic>.from(item)))
      .toList();
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

double? _asNullableDouble(dynamic value) {
  if (value == null) return null;
  return _asDouble(value);
}

DateTime? _parseDate(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

DateTime _parseRequiredDate(dynamic value) {
  return _parseDate(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
}
