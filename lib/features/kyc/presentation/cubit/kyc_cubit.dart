import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/kyc_verification.dart';
import '../../domain/usecases/kyc_usecases.dart';

part 'kyc_state.dart';

class KycCubit extends Cubit<KycState> {
  final GetKycStatusUseCase _getKycStatusUseCase;
  final SubmitKycUseCase _submitKycUseCase;

  KycCubit({
    required GetKycStatusUseCase getKycStatusUseCase,
    required SubmitKycUseCase submitKycUseCase,
  }) : _getKycStatusUseCase = getKycStatusUseCase,
       _submitKycUseCase = submitKycUseCase,
       super(const KycState());

  Future<void> loadStatus() async {
    emit(state.copyWith(viewStatus: KycViewStatus.loading, clearError: true));

    final result = await _getKycStatusUseCase(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          viewStatus: KycViewStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (verification) => emit(
        state.copyWith(
          viewStatus: KycViewStatus.loaded,
          verification: verification,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> submit({
    required String selfieUrl,
    required String idCardFrontUrl,
    required String idCardBackUrl,
  }) async {
    emit(
      state.copyWith(viewStatus: KycViewStatus.submitting, clearError: true),
    );

    final result = await _submitKycUseCase(
      SubmitKycParams(
        selfieUrl: selfieUrl,
        idCardFrontUrl: idCardFrontUrl,
        idCardBackUrl: idCardBackUrl,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          viewStatus: KycViewStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (verification) => emit(
        state.copyWith(
          viewStatus: KycViewStatus.submitted,
          verification: verification,
          clearError: true,
        ),
      ),
    );
  }
}
