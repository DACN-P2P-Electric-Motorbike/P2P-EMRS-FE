import 'package:dartz/dartz.dart';
import 'package:fe_capstone_project/features/owner_vehicle/data/models/create_vehicle_params.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/become_owner_response_model.dart';
import '../repositories/become_owner_repository.dart';

/// Use case for becoming an owner
/// Accepts CreateVehicleParams directly and registers the user as owner with their first vehicle
class BecomeOwner
    implements UseCase<BecomeOwnerResponseDto, CreateVehicleParams> {
  final BecomeOwnerRepository repository;

  BecomeOwner(this.repository);

  @override
  Future<Either<Failure, BecomeOwnerResponseDto>> call(
    CreateVehicleParams params,
  ) async {
    return await repository.becomeOwner(params);
  }
}
