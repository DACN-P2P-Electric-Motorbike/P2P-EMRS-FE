import 'package:equatable/equatable.dart';

import '../../domain/entities/financial_summary.dart';

enum FinancialViewStatus { initial, loading, loaded, failure }

class FinancialState extends Equatable {
  final FinancialViewStatus status;
  final FinancialSummaryEntity? summary;
  final String? errorMessage;

  const FinancialState({
    this.status = FinancialViewStatus.initial,
    this.summary,
    this.errorMessage,
  });

  FinancialState copyWith({
    FinancialViewStatus? status,
    FinancialSummaryEntity? summary,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FinancialState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, summary, errorMessage];
}
