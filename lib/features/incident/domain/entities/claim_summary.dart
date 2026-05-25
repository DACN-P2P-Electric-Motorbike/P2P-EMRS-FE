import 'package:equatable/equatable.dart';

import 'incident_report.dart';

enum ClaimWorkflowStatus {
  noClaim,
  open,
  underReview,
  awaitingChargeReview,
  awaitingDepositDecision,
  awaitingPayout,
  resolved;

  static ClaimWorkflowStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'OPEN':
        return ClaimWorkflowStatus.open;
      case 'UNDER_REVIEW':
        return ClaimWorkflowStatus.underReview;
      case 'AWAITING_CHARGE_REVIEW':
        return ClaimWorkflowStatus.awaitingChargeReview;
      case 'AWAITING_DEPOSIT_DECISION':
        return ClaimWorkflowStatus.awaitingDepositDecision;
      case 'AWAITING_PAYOUT':
        return ClaimWorkflowStatus.awaitingPayout;
      case 'RESOLVED':
        return ClaimWorkflowStatus.resolved;
      case 'NO_CLAIM':
      default:
        return ClaimWorkflowStatus.noClaim;
    }
  }

  String get displayText {
    switch (this) {
      case ClaimWorkflowStatus.noClaim:
        return 'Chưa có yêu cầu';
      case ClaimWorkflowStatus.open:
        return 'Mới mở';
      case ClaimWorkflowStatus.underReview:
        return 'Đang xét duyệt';
      case ClaimWorkflowStatus.awaitingChargeReview:
        return 'Chờ duyệt phí';
      case ClaimWorkflowStatus.awaitingDepositDecision:
        return 'Chờ quyết định cọc';
      case ClaimWorkflowStatus.awaitingPayout:
        return 'Chờ payout owner';
      case ClaimWorkflowStatus.resolved:
        return 'Đã xử lý';
    }
  }

  bool get isActive => this != ClaimWorkflowStatus.noClaim;
}

class ClaimSummaryTotalsEntity extends Equatable {
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

  const ClaimSummaryTotalsEntity({
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

  @override
  List<Object?> get props => [
    incidentCount,
    openIncidentCount,
    unresolvedIncidentCount,
    pendingChargeAmount,
    approvedChargeAmount,
    capturedChargeAmount,
    finalizedChargeAmount,
    heldDepositAmount,
    releasableDepositAmount,
    ownerPayoutAmount,
  ];
}

class ClaimBlockerEntity extends Equatable {
  final String code;
  final String label;
  final int count;
  final bool blocksDepositRelease;
  final bool blocksOwnerPayout;

  const ClaimBlockerEntity({
    required this.code,
    required this.label,
    required this.count,
    required this.blocksDepositRelease,
    required this.blocksOwnerPayout,
  });

  @override
  List<Object?> get props => [
    code,
    label,
    count,
    blocksDepositRelease,
    blocksOwnerPayout,
  ];
}

class ClaimNextActionEntity extends Equatable {
  final String actor;
  final String action;
  final String reason;
  final String priority;

  const ClaimNextActionEntity({
    required this.actor,
    required this.action,
    required this.reason,
    required this.priority,
  });

  @override
  List<Object?> get props => [actor, action, reason, priority];
}

class ClaimTimelineEventEntity extends Equatable {
  final String type;
  final String label;
  final String? status;
  final double? amount;
  final DateTime occurredAt;
  final String? sourceId;
  final String? actorId;

  const ClaimTimelineEventEntity({
    required this.type,
    required this.label,
    this.status,
    this.amount,
    required this.occurredAt,
    this.sourceId,
    this.actorId,
  });

  @override
  List<Object?> get props => [
    type,
    label,
    status,
    amount,
    occurredAt,
    sourceId,
    actorId,
  ];
}

class ClaimCaseSlaSnapshotEntity extends Equatable {
  final String status;
  final String stage;
  final DateTime? dueAt;
  final String label;
  final int remainingMinutes;
  final int overdueMinutes;
  final int escalationLevel;

  const ClaimCaseSlaSnapshotEntity({
    required this.status,
    required this.stage,
    this.dueAt,
    required this.label,
    required this.remainingMinutes,
    required this.overdueMinutes,
    required this.escalationLevel,
  });

  bool get isOverdue => status == 'OVERDUE';
  bool get isAtRisk => status == 'AT_RISK';
  bool get isCompleted => status == 'COMPLETED';

  @override
  List<Object?> get props => [
    status,
    stage,
    dueAt,
    label,
    remainingMinutes,
    overdueMinutes,
    escalationLevel,
  ];
}

class ClaimCaseSnapshotEntity extends Equatable {
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
  final ClaimCaseSlaSnapshotEntity? sla;

  const ClaimCaseSnapshotEntity({
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
  });

  bool get isFinalized =>
      status == 'APPROVED' ||
      status == 'REJECTED' ||
      status == 'RESOLVED' ||
      status == 'CANCELLED';

  @override
  List<Object?> get props => [
    id,
    caseNumber,
    status,
    outcome,
    summary,
    firstDecision,
    firstReviewedAt,
    secondDecision,
    secondReviewedAt,
    resolvedAt,
    sla,
  ];
}

class BookingClaimSummaryEntity extends Equatable {
  final String bookingId;
  final ClaimWorkflowStatus status;
  final String statusLabel;
  final ClaimCaseSnapshotEntity? claimCase;
  final ClaimSummaryTotalsEntity totals;
  final List<ClaimBlockerEntity> blockers;
  final List<ClaimNextActionEntity> nextActions;
  final List<ClaimTimelineEventEntity> timeline;
  final List<IncidentReportEntity> incidents;
  final bool canReleaseDeposit;
  final bool canProcessPayout;

  const BookingClaimSummaryEntity({
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

  bool get hasActiveClaim =>
      status.isActive || incidents.isNotEmpty || blockers.isNotEmpty;

  @override
  List<Object?> get props => [
    bookingId,
    status,
    statusLabel,
    claimCase,
    totals,
    blockers,
    nextActions,
    timeline,
    incidents,
    canReleaseDeposit,
    canProcessPayout,
  ];
}
