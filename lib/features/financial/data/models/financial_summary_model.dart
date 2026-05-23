import '../../domain/entities/financial_summary.dart';

class DepositLedgerModel {
  final String id;
  final String bookingId;
  final String? paymentId;
  final String status;
  final double heldAmount;
  final double pendingChargeAmount;
  final double capturedAmount;
  final double releasedAmount;
  final double refundedAmount;
  final String? notes;
  final DateTime? heldAt;
  final DateTime? releaseDueAt;
  final DateTime? releasedAt;
  final DateTime? disputedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DepositLedgerModel({
    required this.id,
    required this.bookingId,
    this.paymentId,
    required this.status,
    required this.heldAmount,
    required this.pendingChargeAmount,
    required this.capturedAmount,
    required this.releasedAmount,
    required this.refundedAmount,
    this.notes,
    this.heldAt,
    this.releaseDueAt,
    this.releasedAt,
    this.disputedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DepositLedgerModel.fromJson(Map<String, dynamic> json) {
    return DepositLedgerModel(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      paymentId: json['paymentId'] as String?,
      status: json['status'] as String? ?? 'NOT_HELD',
      heldAmount: _asDouble(json['heldAmount']),
      pendingChargeAmount: _asDouble(json['pendingChargeAmount']),
      capturedAmount: _asDouble(json['capturedAmount']),
      releasedAmount: _asDouble(json['releasedAmount']),
      refundedAmount: _asDouble(json['refundedAmount']),
      notes: json['notes'] as String?,
      heldAt: _parseDate(json['heldAt']),
      releaseDueAt: _parseDate(json['releaseDueAt']),
      releasedAt: _parseDate(json['releasedAt']),
      disputedAt: _parseDate(json['disputedAt']),
      createdAt: _parseRequiredDate(json['createdAt']),
      updatedAt: _parseRequiredDate(json['updatedAt']),
    );
  }

  DepositLedgerEntity toEntity() {
    return DepositLedgerEntity(
      id: id,
      bookingId: bookingId,
      paymentId: paymentId,
      status: DepositLedgerStatus.fromString(status),
      heldAmount: heldAmount,
      pendingChargeAmount: pendingChargeAmount,
      capturedAmount: capturedAmount,
      releasedAmount: releasedAmount,
      refundedAmount: refundedAmount,
      notes: notes,
      heldAt: heldAt,
      releaseDueAt: releaseDueAt,
      releasedAt: releasedAt,
      disputedAt: disputedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class PostTripChargeModel {
  final String id;
  final String bookingId;
  final String? tripId;
  final String type;
  final String status;
  final String source;
  final double amount;
  final double? quantity;
  final double? unitPrice;
  final String description;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostTripChargeModel({
    required this.id,
    required this.bookingId,
    this.tripId,
    required this.type,
    required this.status,
    required this.source,
    required this.amount,
    this.quantity,
    this.unitPrice,
    required this.description,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostTripChargeModel.fromJson(Map<String, dynamic> json) {
    return PostTripChargeModel(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      tripId: json['tripId'] as String?,
      type: json['type'] as String? ?? 'OTHER',
      status: json['status'] as String? ?? 'PENDING_REVIEW',
      source: json['source'] as String? ?? 'SYSTEM',
      amount: _asDouble(json['amount']),
      quantity: _asNullableDouble(json['quantity']),
      unitPrice: _asNullableDouble(json['unitPrice']),
      description: json['description'] as String? ?? '',
      reviewedBy: json['reviewedBy'] as String?,
      reviewedAt: _parseDate(json['reviewedAt']),
      createdAt: _parseRequiredDate(json['createdAt']),
      updatedAt: _parseRequiredDate(json['updatedAt']),
    );
  }

  PostTripChargeEntity toEntity() {
    return PostTripChargeEntity(
      id: id,
      bookingId: bookingId,
      tripId: tripId,
      type: PostTripChargeType.fromString(type),
      status: PostTripChargeStatus.fromString(status),
      source: PostTripChargeSource.fromString(source),
      amount: amount,
      quantity: quantity,
      unitPrice: unitPrice,
      description: description,
      reviewedBy: reviewedBy,
      reviewedAt: reviewedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class FinancialSummaryModel {
  final String bookingId;
  final DepositLedgerModel? deposit;
  final List<PostTripChargeModel> charges;
  final double totalPendingCharges;
  final double totalApprovedCharges;
  final double totalCapturedCharges;
  final double releasableDeposit;

  const FinancialSummaryModel({
    required this.bookingId,
    this.deposit,
    required this.charges,
    required this.totalPendingCharges,
    required this.totalApprovedCharges,
    required this.totalCapturedCharges,
    required this.releasableDeposit,
  });

  factory FinancialSummaryModel.fromJson(Map<String, dynamic> json) {
    final chargesJson = json['charges'];
    return FinancialSummaryModel(
      bookingId: json['bookingId'] as String,
      deposit: json['deposit'] is Map
          ? DepositLedgerModel.fromJson(
              Map<String, dynamic>.from(json['deposit'] as Map),
            )
          : null,
      charges: chargesJson is List
          ? chargesJson.whereType<Map>().map((charge) {
              return PostTripChargeModel.fromJson(
                Map<String, dynamic>.from(charge),
              );
            }).toList()
          : const [],
      totalPendingCharges: _asDouble(json['totalPendingCharges']),
      totalApprovedCharges: _asDouble(json['totalApprovedCharges']),
      totalCapturedCharges: _asDouble(json['totalCapturedCharges']),
      releasableDeposit: _asDouble(json['releasableDeposit']),
    );
  }

  FinancialSummaryEntity toEntity() {
    return FinancialSummaryEntity(
      bookingId: bookingId,
      deposit: deposit?.toEntity(),
      charges: charges.map((charge) => charge.toEntity()).toList(),
      totalPendingCharges: totalPendingCharges,
      totalApprovedCharges: totalApprovedCharges,
      totalCapturedCharges: totalCapturedCharges,
      releasableDeposit: releasableDeposit,
    );
  }
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
