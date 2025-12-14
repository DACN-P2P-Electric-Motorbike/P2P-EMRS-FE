import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/register_params.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Register use case - handles user registration
class RegisterUseCase implements UseCase<UserEntity, RegisterParams> {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(RegisterParams params) async {
    return await _repository.register(params);
  }
}
