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

class ClaimCaseSlaSnapshotModel {
  final String status;
  final String stage;
  final DateTime? dueAt;
  final String label;
  final int remainingMinutes;
  final int overdueMinutes;
  final int escalationLevel;

  const ClaimCaseSlaSnapshotModel({
    required this.status,
    required this.stage,
    this.dueAt,
    required this.label,
    required this.remainingMinutes,
    required this.overdueMinutes,
    required this.escalationLevel,
  });

  factory ClaimCaseSlaSnapshotModel.fromJson(Map<String, dynamic> json) {
    return ClaimCaseSlaSnapshotModel(
      status: json['status'] as String? ?? '',
      stage: json['stage'] as String? ?? '',
      dueAt: _parseDate(json['dueAt']),
      label: json['label'] as String? ?? '',
      remainingMinutes: _asInt(json['remainingMinutes']),
      overdueMinutes: _asInt(json['overdueMinutes']),
      escalationLevel: _asInt(json['escalationLevel']),
    );
  }

  ClaimCaseSlaSnapshotEntity toEntity() {
    return ClaimCaseSlaSnapshotEntity(
      status: status,
      stage: stage,
      dueAt: dueAt,
      label: label,
      remainingMinutes: remainingMinutes,
      overdueMinutes: overdueMinutes,
      escalationLevel: escalationLevel,
    );
  }
}

class ClaimProtectionSettlementModel {
  final String status;
  final String protectionPlan;
  final double eligibleDamageAmount;
  final double nonCoveredChargeAmount;
  final double deductibleAmount;
  final double deductibleAppliedAmount;
  final double coverageLimit;
  final double platformCoverageAmount;
  final double renterLiabilityAmount;
  final double excessAboveCoverageAmount;

  const ClaimProtectionSettlementModel({
    required this.status,
    required this.protectionPlan,
    required this.eligibleDamageAmount,
    required this.nonCoveredChargeAmount,
    required this.deductibleAmount,
    required this.deductibleAppliedAmount,
    required this.coverageLimit,
    required this.platformCoverageAmount,
    required this.renterLiabilityAmount,
    required this.excessAboveCoverageAmount,
  });

  factory ClaimProtectionSettlementModel.fromJson(Map<String, dynamic> json) {
    return ClaimProtectionSettlementModel(
      status: json['status'] as String? ?? '',
      protectionPlan: json['protectionPlan'] as String? ?? '',
      eligibleDamageAmount: _asDouble(json['eligibleDamageAmount']),
      nonCoveredChargeAmount: _asDouble(json['nonCoveredChargeAmount']),
      deductibleAmount: _asDouble(json['deductibleAmount']),
      deductibleAppliedAmount: _asDouble(json['deductibleAppliedAmount']),
      coverageLimit: _asDouble(json['coverageLimit']),
      platformCoverageAmount: _asDouble(json['platformCoverageAmount']),
      renterLiabilityAmount: _asDouble(json['renterLiabilityAmount']),
      excessAboveCoverageAmount: _asDouble(json['excessAboveCoverageAmount']),
    );
  }

  ClaimProtectionSettlementEntity toEntity() {
    return ClaimProtectionSettlementEntity(
      status: status,
      protectionPlan: protectionPlan,
      eligibleDamageAmount: eligibleDamageAmount,
      nonCoveredChargeAmount: nonCoveredChargeAmount,
      deductibleAmount: deductibleAmount,
      deductibleAppliedAmount: deductibleAppliedAmount,
      coverageLimit: coverageLimit,
      platformCoverageAmount: platformCoverageAmount,
      renterLiabilityAmount: renterLiabilityAmount,
      excessAboveCoverageAmount: excessAboveCoverageAmount,
    );
  }
}

class ClaimCaseSnapshotModel {
  final String id;
  final String caseNumber;
  final String status;
  final String? outcome;
  final String? summary;
  final String? firstDecision;
  final DateTime? firstReviewedAt;
  final String? secondDecision;
  final DateTime? secondReviewedAt;
  final DateTime? resolvedAt;
  final ClaimCaseSlaSnapshotModel? sla;
  final ClaimProtectionSettlementModel? protectionSettlement;

  const ClaimCaseSnapshotModel({
    required this.id,
    required this.caseNumber,
    required this.status,
    this.outcome,
    this.summary,
    this.firstDecision,
    this.firstReviewedAt,
    this.secondDecision,
    this.secondReviewedAt,
    this.resolvedAt,
    this.sla,
    this.protectionSettlement,
  });

  factory ClaimCaseSnapshotModel.fromJson(Map<String, dynamic> json) {
    final slaJson = _asNullableMap(json['sla']);
    final protectionSettlementJson = _asNullableMap(
      json['protectionSettlement'],
    );
    return ClaimCaseSnapshotModel(
      id: json['id'] as String? ?? '',
      caseNumber: json['caseNumber'] as String? ?? '',
      status: json['status'] as String? ?? '',
      outcome: json['outcome'] as String?,
      summary: json['summary'] as String?,
      firstDecision: json['firstDecision'] as String?,
      firstReviewedAt: _parseDate(json['firstReviewedAt']),
      secondDecision: json['secondDecision'] as String?,
      secondReviewedAt: _parseDate(json['secondReviewedAt']),
      resolvedAt: _parseDate(json['resolvedAt']),
      sla: slaJson == null ? null : ClaimCaseSlaSnapshotModel.fromJson(slaJson),
      protectionSettlement: protectionSettlementJson == null
          ? null
          : ClaimProtectionSettlementModel.fromJson(protectionSettlementJson),
    );
  }

  ClaimCaseSnapshotEntity toEntity() {
    return ClaimCaseSnapshotEntity(
      id: id,
      caseNumber: caseNumber,
      status: status,
      outcome: outcome,
      summary: summary,
      firstDecision: firstDecision,
      firstReviewedAt: firstReviewedAt,
      secondDecision: secondDecision,
      secondReviewedAt: secondReviewedAt,
      resolvedAt: resolvedAt,
      sla: sla?.toEntity(),
      protectionSettlement: protectionSettlement?.toEntity(),
    );
  }
}

class BookingClaimSummaryModel {
  final String bookingId;
  final String status;
  final String statusLabel;
  final ClaimCaseSnapshotModel? claimCase;
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
    this.claimCase,
    required this.totals,
    required this.blockers,
    required this.nextActions,
    required this.timeline,
    required this.incidents,
    required this.canReleaseDeposit,
    required this.canProcessPayout,
  });

  factory BookingClaimSummaryModel.empty(String bookingId) {
    return BookingClaimSummaryModel(
      bookingId: bookingId,
      status: 'NO_CLAIM',
      statusLabel: '',
      totals: const ClaimSummaryTotalsModel(
        incidentCount: 0,
        openIncidentCount: 0,
        unresolvedIncidentCount: 0,
        pendingChargeAmount: 0,
        approvedChargeAmount: 0,
        capturedChargeAmount: 0,
        finalizedChargeAmount: 0,
        heldDepositAmount: 0,
        releasableDepositAmount: 0,
        ownerPayoutAmount: 0,
      ),
      blockers: const [],
      nextActions: const [],
      timeline: const [],
      incidents: const [],
      canReleaseDeposit: true,
      canProcessPayout: true,
    );
  }

  factory BookingClaimSummaryModel.fromJson(Map<String, dynamic> json) {
    final claimCaseJson = _asNullableMap(json['claimCase']);
    return BookingClaimSummaryModel(
      bookingId: json['bookingId'] as String? ?? '',
      status: json['status'] as String? ?? 'NO_CLAIM',
      statusLabel: json['statusLabel'] as String? ?? '',
      claimCase: claimCaseJson == null
          ? null
          : ClaimCaseSnapshotModel.fromJson(claimCaseJson),
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
      claimCase: claimCase?.toEntity(),
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

Map<String, dynamic>? _asNullableMap(dynamic value) {
  if (value == null) return null;
  final mapped = _asMap(value);
  return mapped.isEmpty ? null : mapped;
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
