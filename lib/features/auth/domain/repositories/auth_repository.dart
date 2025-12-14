import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/register_params.dart';
import '../entities/user.dart';

/// Abstract repository interface for authentication
/// Following Dependency Inversion Principle - Domain layer defines the contract
abstract class AuthRepository {
  /// Login user with email and password
  /// Returns Either<Failure, UserEntity>
  Future<Either<Failure, UserEntity>> login(String email, String password);

  /// Register a new user
  /// Returns Either<Failure, UserEntity>
  Future<Either<Failure, UserEntity>> register(RegisterParams params);

  /// Logout current user
  /// Returns Either<Failure, void>
  Future<Either<Failure, void>> logout();

  /// Check if user is logged in
  /// Returns Either<Failure, bool>
  Future<Either<Failure, bool>> isLoggedIn();

  /// Get current user profile
  /// Returns Either<Failure, UserEntity>
  Future<Either<Failure, UserEntity>> getProfile();
}
