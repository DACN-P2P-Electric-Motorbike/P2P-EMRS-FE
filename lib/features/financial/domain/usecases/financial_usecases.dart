import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/financial_summary.dart';
import '../repositories/financial_repository.dart';

class GetFinancialSummaryParams {
  final String bookingId;

  const GetFinancialSummaryParams(this.bookingId);
}

class GetFinancialSummaryUseCase
    implements UseCase<FinancialSummaryEntity, GetFinancialSummaryParams> {
  final FinancialRepository repository;

  GetFinancialSummaryUseCase(this.repository);

  @override
  Future<Either<Failure, FinancialSummaryEntity>> call(
    GetFinancialSummaryParams params,
  ) {
    return repository.getBookingFinancialSummary(params.bookingId);
  }
}

class CreateManualPostTripChargeParams {
  final String bookingId;
  final PostTripChargeType type;
  final double amount;
  final String description;
  final double? quantity;
  final double? unitPrice;
  final List<String>? evidenceUrls;

  const CreateManualPostTripChargeParams({
    required this.bookingId,
    required this.type,
    required this.amount,
    required this.description,
    this.quantity,
    this.unitPrice,
    this.evidenceUrls,
  });
}

class CreateManualPostTripChargeUseCase
    implements
        UseCase<FinancialSummaryEntity, CreateManualPostTripChargeParams> {
  final FinancialRepository repository;

  CreateManualPostTripChargeUseCase(this.repository);

  @override
  Future<Either<Failure, FinancialSummaryEntity>> call(
    CreateManualPostTripChargeParams params,
  ) {
    return repository.createManualPostTripCharge(
      bookingId: params.bookingId,
      type: params.type,
      amount: params.amount,
      description: params.description,
      quantity: params.quantity,
      unitPrice: params.unitPrice,
      evidenceUrls: params.evidenceUrls,
    );
  }
}

class DisputePostTripChargeParams {
  final String chargeId;
  final String reason;
  final List<String>? evidenceUrls;

  const DisputePostTripChargeParams({
    required this.chargeId,
    required this.reason,
    this.evidenceUrls,
  });
}

class DisputePostTripChargeUseCase
    implements UseCase<FinancialSummaryEntity, DisputePostTripChargeParams> {
  final FinancialRepository repository;

  DisputePostTripChargeUseCase(this.repository);

  @override
  Future<Either<Failure, FinancialSummaryEntity>> call(
    DisputePostTripChargeParams params,
  ) {
    return repository.disputePostTripCharge(
      chargeId: params.chargeId,
      reason: params.reason,
      evidenceUrls: params.evidenceUrls,
    );
  }
}
