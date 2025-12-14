import 'package:dartz/dartz.dart';
import 'package:fe_capstone_project/features/owner_vehicle/data/models/create_vehicle_params.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/become_owner_response_model.dart';

/// Repository for becoming an owner
abstract class BecomeOwnerRepository {
  Future<Either<Failure, BecomeOwnerResponseDto>> becomeOwner(
    CreateVehicleParams vehicleData,
  );
}
