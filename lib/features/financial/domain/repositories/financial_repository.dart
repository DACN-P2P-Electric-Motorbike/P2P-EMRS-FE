import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/financial_summary.dart';

abstract class FinancialRepository {
  Future<Either<Failure, FinancialSummaryEntity>> getBookingFinancialSummary(
    String bookingId,
  );

  Future<Either<Failure, FinancialSummaryEntity>> createManualPostTripCharge({
    required String bookingId,
    required PostTripChargeType type,
    required double amount,
    required String description,
    double? quantity,
    double? unitPrice,
    List<String>? evidenceUrls,
  });
}
