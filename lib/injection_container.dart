import 'package:get_it/get_it.dart';

// Core
import 'core/network/dio_client.dart';
import 'core/storage/storage_service.dart';
import 'core/services/upload_service.dart';

// Auth Feature - Data Layer
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';

// Auth Feature - Domain Layer
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/check_auth_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';

// Auth Feature - Presentation Layer
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Owner Vehicle Feature - Data Layer
import 'features/owner_vehicle/data/datasources/owner_vehicle_remote_data_source.dart';
import 'features/owner_vehicle/data/repositories/owner_vehicle_repository_impl.dart';

// Owner Vehicle Feature - Domain Layer
import 'features/owner_vehicle/domain/repositories/owner_vehicle_repository.dart';
import 'features/owner_vehicle/domain/usecases/get_my_vehicles_usecase.dart';
import 'features/owner_vehicle/domain/usecases/get_vehicle_by_id_usecase.dart';
import 'features/owner_vehicle/domain/usecases/register_vehicle_usecase.dart';
import 'features/owner_vehicle/domain/usecases/update_vehicle_usecase.dart';

// Owner Vehicle Feature - Presentation Layer
import 'features/owner_vehicle/presentation/bloc/owner_vehicle_bloc.dart';

import 'features/renter/data/datasources/become_owner_remote_datasource.dart';
import 'features/renter/data/repositories/become_owner_repository_impl.dart';
import 'features/renter/domain/repositories/become_owner_repository.dart';
import 'features/renter/domain/usecases/become_owner.dart';
import 'features/renter/presentation/bloc/become_owner_cubiit.dart';

import 'features/vehicle/data/datasources/vehicle_remote_datasource.dart';
import 'features/vehicle/data/repositories/vehicle_repository_impl.dart';

// Vehicle Feature - Domain Layer
import 'features/vehicle/domain/repositories/vehicle_repository.dart';
import 'features/vehicle/domain/usecases/get_available_vehicles.dart';
import 'features/vehicle/domain/usecases/get_vehicle_by_id.dart';

// Vehicle Feature - Presentation Layer
import 'features/vehicle/presentation/bloc/vehicles_list_cubit.dart';
import 'features/vehicle/presentation/bloc/vehicle_detail_cubit.dart';

/// Global service locator instance
final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> init() async {
  //============================================================================
  // CORE
  //============================================================================

  // Storage Service - Singleton
  sl.registerLazySingleton<StorageService>(() => StorageService());

  // Dio Client - Singleton (depends on StorageService)
  sl.registerLazySingleton<DioClient>(() => DioClient(storageService: sl()));

  // Upload Service - Singleton (depends on DioClient)
  sl.registerLazySingleton<UploadService>(() => UploadService(dioClient: sl()));

  //============================================================================
  // FEATURES - AUTH
  //============================================================================

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dioClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), storageService: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthUseCase(sl()));

  // BLoC - Factory (new instance each time)
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      checkAuthUseCase: sl(),
      authRepository: sl(),
    ),
  );

  //============================================================================
  // FEATURES - OWNER VEHICLE
  //============================================================================

  // Data Sources
  sl.registerLazySingleton<OwnerVehicleRemoteDataSource>(
    () => OwnerVehicleRemoteDataSourceImpl(dioClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<OwnerVehicleRepository>(
    () => OwnerVehicleRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetMyVehiclesUseCase(sl()));
  sl.registerLazySingleton(() => RegisterVehicleUseCase(sl()));
  sl.registerLazySingleton(() => UpdateVehicleUseCase(sl()));
  sl.registerLazySingleton(() => GetVehicleByIdUseCase(sl()));

  // BLoC - Factory (new instance each time)
  sl.registerFactory(
    () => OwnerVehicleBloc(
      getMyVehiclesUseCase: sl(),
      registerVehicleUseCase: sl(),
      updateVehicleUseCase: sl(),
      getVehicleByIdUseCase: sl(),
    ),
  );

  //============================================================================
  // FEATURES - VEHICLE
  //============================================================================

  sl.registerFactory(() => VehicleListCubit(getAvailableVehicles: sl()));

  sl.registerFactory(() => VehicleDetailCubit(getVehicleById: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetAvailableVehicles(sl()));
  sl.registerLazySingleton(() => GetVehicleById(sl()));

  // Repository
  sl.registerLazySingleton<VehicleRepository>(
    () => VehicleRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<VehicleRemoteDataSource>(
    () => VehicleRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<BecomeOwnerRemoteDataSource>(
    () => BecomeOwnerRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<BecomeOwnerRepository>(
    () => BecomeOwnerRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(() => BecomeOwner(sl()));

  sl.registerFactory(() => BecomeOwnerCubit(becomeOwner: sl()));
}
