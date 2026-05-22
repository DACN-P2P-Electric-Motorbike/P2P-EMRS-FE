import 'package:equatable/equatable.dart';

enum KycStatus {
  notSubmitted,
  pending,
  approved,
  rejected;

  static KycStatus fromApi(String? value) {
    switch (value?.toUpperCase()) {
      case 'PENDING':
        return KycStatus.pending;
      case 'APPROVED':
        return KycStatus.approved;
      case 'REJECTED':
        return KycStatus.rejected;
      default:
        return KycStatus.notSubmitted;
    }
  }

  String get displayName {
    switch (this) {
      case KycStatus.notSubmitted:
        return 'Chưa xác minh';
      case KycStatus.pending:
        return 'Đang chờ duyệt';
      case KycStatus.approved:
        return 'Đã xác minh';
      case KycStatus.rejected:
        return 'Cần gửi lại';
    }
  }
}

class KycVerification extends Equatable {
  final String? id;
  final KycStatus status;
  final String? selfieUrl;
  final String? idCardFrontUrl;
  final String? idCardBackUrl;
  final String? rejectionReason;
  final DateTime? reviewedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const KycVerification({
    this.id,
    required this.status,
    this.selfieUrl,
    this.idCardFrontUrl,
    this.idCardBackUrl,
    this.rejectionReason,
    this.reviewedAt,
    this.createdAt,
    this.updatedAt,
  });

  bool get canSubmit =>
      status == KycStatus.notSubmitted || status == KycStatus.rejected;

  @override
  List<Object?> get props => [
    id,
    status,
    selfieUrl,
    idCardFrontUrl,
    idCardBackUrl,
    rejectionReason,
    reviewedAt,
    createdAt,
    updatedAt,
  ];
}
