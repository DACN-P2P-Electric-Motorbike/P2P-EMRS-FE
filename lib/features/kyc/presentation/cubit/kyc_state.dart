part of 'kyc_cubit.dart';

enum KycViewStatus { initial, loading, loaded, submitting, submitted, error }

class KycState extends Equatable {
  final KycViewStatus viewStatus;
  final KycVerification verification;
  final String? errorMessage;

  const KycState({
    this.viewStatus = KycViewStatus.initial,
    this.verification = const KycVerification(status: KycStatus.notSubmitted),
    this.errorMessage,
  });

  KycState copyWith({
    KycViewStatus? viewStatus,
    KycVerification? verification,
    String? errorMessage,
    bool clearError = false,
  }) {
    return KycState(
      viewStatus: viewStatus ?? this.viewStatus,
      verification: verification ?? this.verification,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool get isBusy =>
      viewStatus == KycViewStatus.loading ||
      viewStatus == KycViewStatus.submitting;

  @override
  List<Object?> get props => [viewStatus, verification, errorMessage];
}
