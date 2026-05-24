import '../../domain/entities/kyc_verification.dart';

class KycVerificationModel extends KycVerification {
  const KycVerificationModel({
    super.id,
    required super.status,
    super.selfieUrl,
    super.idCardFrontUrl,
    super.idCardBackUrl,
    super.rejectionReason,
    super.reviewedAt,
    super.createdAt,
    super.updatedAt,
  });

  factory KycVerificationModel.notSubmitted() {
    return const KycVerificationModel(status: KycStatus.notSubmitted);
  }

  factory KycVerificationModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value is! String || value.isEmpty) return null;
      return DateTime.tryParse(value);
    }

    return KycVerificationModel(
      id: json['id'] as String?,
      status: KycStatus.fromApi(json['status'] as String?),
      selfieUrl: json['selfieUrl'] as String?,
      idCardFrontUrl: json['idCardFrontUrl'] as String?,
      idCardBackUrl: json['idCardBackUrl'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      reviewedAt: parseDate(json['reviewedAt']),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  factory KycVerificationModel.fromStatusResponse(Map<String, dynamic> json) {
    final verification = json['verification'];
    if (verification is Map) {
      return KycVerificationModel.fromJson(
        Map<String, dynamic>.from(verification),
      );
    }
    return KycVerificationModel(
      status: KycStatus.fromApi(json['status'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.name,
      'selfieUrl': selfieUrl,
      'idCardFrontUrl': idCardFrontUrl,
      'idCardBackUrl': idCardBackUrl,
      'rejectionReason': rejectionReason,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
