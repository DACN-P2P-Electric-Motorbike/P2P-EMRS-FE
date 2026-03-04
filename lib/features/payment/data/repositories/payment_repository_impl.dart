import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource _remoteDataSource;

  PaymentRepositoryImpl({required PaymentRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  String _methodToString(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.payos:
        return 'PAYOS';
      case PaymentMethod.momo:
        return 'MOMO';
      case PaymentMethod.creditCard:
        return 'CREDIT_CARD';
      case PaymentMethod.cash:
        return 'CASH';
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> createPayment({
    required String bookingId,
    required PaymentMethod method,
  }) async {
    try {
      final payment = await _remoteDataSource.createPayment(
        bookingId: bookingId,
        method: _methodToString(method),
      );
      return Right(payment.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentEntity?>> getPaymentByBookingId(
    String bookingId,
  ) async {
    try {
      final payment = await _remoteDataSource.getPaymentByBookingId(bookingId);
      return Right(payment?.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> getPaymentById(
    String paymentId,
  ) async {
    try {
      final payment = await _remoteDataSource.getPaymentById(paymentId);
      return Right(payment.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> simulateSuccess(
    String paymentId,
  ) async {
    try {
      final payment = await _remoteDataSource.simulateSuccess(paymentId);
      return Right(payment.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, String>>> initiatePayOS(
    String paymentId,
  ) async {
    try {
      final result = await _remoteDataSource.initiatePayOS(paymentId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, String>>> initiateMoMo(
    String paymentId,
  ) async {
    try {
      final result = await _remoteDataSource.initiateMoMo(paymentId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> refund(String paymentId) async {
    try {
      final payment = await _remoteDataSource.refund(paymentId);
      return Right(payment.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
