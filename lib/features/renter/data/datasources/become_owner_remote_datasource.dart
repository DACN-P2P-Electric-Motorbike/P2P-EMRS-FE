import 'package:dio/dio.dart';
import 'package:fe_capstone_project/features/owner_vehicle/data/models/create_vehicle_params.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/become_owner_response_model.dart';

/// Remote data source for become owner operations
abstract class BecomeOwnerRemoteDataSource {
  Future<BecomeOwnerResponseDto> becomeOwner(CreateVehicleParams vehicleData);
}

class BecomeOwnerRemoteDataSourceImpl implements BecomeOwnerRemoteDataSource {
  final DioClient _dioClient;

  BecomeOwnerRemoteDataSourceImpl({required DioClient dioClient})
    : _dioClient = dioClient;

  @override
  Future<BecomeOwnerResponseDto> becomeOwner(
    CreateVehicleParams vehicleData,
  ) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.authBecomeOwner,
        data: vehicleData.toJson(),
      );

      return BecomeOwnerResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }
}
