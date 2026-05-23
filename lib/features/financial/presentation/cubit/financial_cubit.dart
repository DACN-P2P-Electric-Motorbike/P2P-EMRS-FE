import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/financial_usecases.dart';
import 'financial_state.dart';

class FinancialCubit extends Cubit<FinancialState> {
  final GetFinancialSummaryUseCase _getFinancialSummary;

  FinancialCubit({required GetFinancialSummaryUseCase getFinancialSummary})
    : _getFinancialSummary = getFinancialSummary,
      super(const FinancialState());

  Future<void> load(String bookingId) async {
    emit(state.copyWith(status: FinancialViewStatus.loading, clearError: true));
    final result = await _getFinancialSummary(
      GetFinancialSummaryParams(bookingId),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: FinancialViewStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (summary) => emit(
        state.copyWith(
          status: FinancialViewStatus.loaded,
          summary: summary,
          clearError: true,
        ),
      ),
    );
  }
}
