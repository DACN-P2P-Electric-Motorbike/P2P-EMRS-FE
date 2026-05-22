import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/kyc_verification.dart';

abstract class KycRepository {
  Future<Either<Failure, KycVerification>> getStatus();

  Future<Either<Failure, KycVerification>> submit({
    required String selfieUrl,
    required String idCardFrontUrl,
    required String idCardBackUrl,
  });
}
