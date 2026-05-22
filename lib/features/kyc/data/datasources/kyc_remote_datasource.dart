import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/kyc_verification_model.dart';

abstract class KycRemoteDataSource {
  Future<KycVerificationModel> getStatus();

  Future<KycVerificationModel> submit({
    required String selfieUrl,
    required String idCardFrontUrl,
    required String idCardBackUrl,
  });
}

class KycRemoteDataSourceImpl implements KycRemoteDataSource {
  final DioClient _dioClient;

  KycRemoteDataSourceImpl({required DioClient dioClient})
    : _dioClient = dioClient;

  @override
  Future<KycVerificationModel> getStatus() async {
    try {
      final response = await _dioClient.get(ApiConstants.kycStatus);
      return KycVerificationModel.fromStatusResponse(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<KycVerificationModel> submit({
    required String selfieUrl,
    required String idCardFrontUrl,
    required String idCardBackUrl,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.kycSubmit,
        data: {
          'selfieUrl': selfieUrl,
          'idCardFrontUrl': idCardFrontUrl,
          'idCardBackUrl': idCardBackUrl,
        },
      );
      return KycVerificationModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }
}
