import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/kyc_verification.dart';
import '../repositories/kyc_repository.dart';

class GetKycStatusUseCase implements UseCase<KycVerification, NoParams> {
  final KycRepository repository;

  GetKycStatusUseCase(this.repository);

  @override
  Future<Either<Failure, KycVerification>> call(NoParams params) {
    return repository.getStatus();
  }
}

class SubmitKycUseCase implements UseCase<KycVerification, SubmitKycParams> {
  final KycRepository repository;

  SubmitKycUseCase(this.repository);

  @override
  Future<Either<Failure, KycVerification>> call(SubmitKycParams params) {
    return repository.submit(
      selfieUrl: params.selfieUrl,
      idCardFrontUrl: params.idCardFrontUrl,
      idCardBackUrl: params.idCardBackUrl,
    );
  }
}

class SubmitKycParams extends Equatable {
  final String selfieUrl;
  final String idCardFrontUrl;
  final String idCardBackUrl;

  const SubmitKycParams({
    required this.selfieUrl,
    required this.idCardFrontUrl,
    required this.idCardBackUrl,
  });

  @override
  List<Object?> get props => [selfieUrl, idCardFrontUrl, idCardBackUrl];
}
