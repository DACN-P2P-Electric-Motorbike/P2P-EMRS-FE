import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/availability_summary.dart';
import '../repositories/vehicle_repository.dart';

class GetVehicleAvailabilitySummary
    implements UseCase<VehicleAvailabilitySummary, String> {
  final VehicleRepository repository;

  GetVehicleAvailabilitySummary(this.repository);

  @override
  Future<Either<Failure, VehicleAvailabilitySummary>> call(String vehicleId) {
    return repository.getAvailabilitySummary(vehicleId);
  }
}
