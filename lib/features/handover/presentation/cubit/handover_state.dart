import 'package:equatable/equatable.dart';

import '../../domain/entities/handover.dart';

enum HandoverViewStatus { initial, loading, loaded, submitting, success }

class HandoverState extends Equatable {
  final HandoverViewStatus status;
  final HandoverSummary? summary;
  final VehicleHandover? latestHandover;
  final String? errorMessage;

  const HandoverState({
    this.status = HandoverViewStatus.initial,
    this.summary,
    this.latestHandover,
    this.errorMessage,
  });

  bool get isBusy =>
      status == HandoverViewStatus.loading ||
      status == HandoverViewStatus.submitting;

  HandoverState copyWith({
    HandoverViewStatus? status,
    HandoverSummary? summary,
    VehicleHandover? latestHandover,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HandoverState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      latestHandover: latestHandover ?? this.latestHandover,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, summary, latestHandover, errorMessage];
}
