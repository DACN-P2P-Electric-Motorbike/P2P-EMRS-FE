import 'package:get_it/get_it.dart';

// Core
import 'core/network/dio_client.dart';
import 'core/storage/storage_service.dart';
import 'core/services/upload_service.dart';
import 'core/services/socket_service.dart';
import 'core/services/fcm_service.dart';

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

// Renter Feature
import 'features/renter/data/datasources/become_owner_remote_datasource.dart';
import 'features/renter/data/repositories/become_owner_repository_impl.dart';
import 'features/renter/domain/repositories/become_owner_repository.dart';
import 'features/renter/domain/usecases/become_owner.dart';
import 'features/renter/presentation/bloc/become_owner_cubiit.dart';

// Vehicle Feature - Data Layer
import 'features/vehicle/data/datasources/vehicle_remote_datasource.dart';
import 'features/vehicle/data/repositories/vehicle_repository_impl.dart';

// Vehicle Feature - Domain Layer
import 'features/vehicle/domain/repositories/vehicle_repository.dart';
import 'features/vehicle/domain/usecases/get_available_vehicles.dart';
import 'features/vehicle/domain/usecases/get_vehicle_by_id.dart';

// Vehicle Feature - Presentation Layer
import 'features/vehicle/presentation/bloc/vehicles_list_cubit.dart';
import 'features/vehicle/presentation/bloc/vehicle_detail_cubit.dart';

// Booking Feature - Data Layer
import 'features/booking/data/datasources/booking_remote_datasource.dart';
import 'features/booking/data/repositories/booking_repository_impl.dart';

// Booking Feature - Domain Layer
import 'features/booking/domain/repositories/booking_repository.dart';
import 'features/booking/domain/usecases/create_booking_usecase.dart';
import 'features/booking/domain/usecases/booking_usecases.dart';

// Booking Feature - Presentation Layer
import 'features/booking/presentation/bloc/booking_bloc.dart';

// Notification Feature - Data Layer
import 'features/notification/data/datasources/notification_remote_datasource.dart';
import 'features/notification/data/repositories/notification_repository_impl.dart';

// Notification Feature - Domain Layer
import 'features/notification/domain/repositories/notification_repository.dart';
import 'features/notification/domain/usecases/notification_usecases.dart';

// Notification Feature - Presentation Layer
import 'features/notification/presentation/bloc/notification_bloc.dart';

/// Global service locator instance
final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> init() async {
  //============================================================================
  // CORE SERVICES
  //============================================================================

  // Storage Service - Singleton
  sl.registerLazySingleton<StorageService>(() => StorageService());

  // Dio Client - Singleton (depends on StorageService)
  sl.registerLazySingleton<DioClient>(() => DioClient(storageService: sl()));

  // Upload Service - Singleton (depends on DioClient)
  sl.registerLazySingleton<UploadService>(() => UploadService(dioClient: sl()));

  // Socket Service - Singleton
  sl.registerLazySingleton<SocketService>(() => SocketService());

  // FCM Service - Singleton
  sl.registerLazySingleton<FcmService>(() => FcmService());

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

  // BLoC - Factory
  sl.registerFactory(
    () => OwnerVehicleBloc(
      getMyVehiclesUseCase: sl(),
      registerVehicleUseCase: sl(),
      updateVehicleUseCase: sl(),
      getVehicleByIdUseCase: sl(),
    ),
  );

  //============================================================================
  // FEATURES - VEHICLE (RENTER)
  //============================================================================

  // Data Sources
  sl.registerLazySingleton<VehicleRemoteDataSource>(
    () => VehicleRemoteDataSourceImpl(dioClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<VehicleRepository>(
    () => VehicleRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetAvailableVehicles(sl()));
  sl.registerLazySingleton(() => GetVehicleById(sl()));

  // Cubit - Factory
  sl.registerFactory(() => VehicleListCubit(getAvailableVehicles: sl()));
  sl.registerFactory(() => VehicleDetailCubit(getVehicleById: sl()));

  //============================================================================
  // FEATURES - BECOME OWNER
  //============================================================================

  // Data Sources
  sl.registerLazySingleton<BecomeOwnerRemoteDataSource>(
    () => BecomeOwnerRemoteDataSourceImpl(dioClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<BecomeOwnerRepository>(
    () => BecomeOwnerRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => BecomeOwner(sl()));

  // Cubit - Factory
  sl.registerFactory(() => BecomeOwnerCubit(becomeOwner: sl()));

  //============================================================================
  // FEATURES - BOOKING
  //============================================================================

  // Data Sources
  sl.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSourceImpl(dioClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => CreateBookingUseCase(sl()));
  sl.registerLazySingleton(() => GetRenterBookingsUseCase(sl()));
  sl.registerLazySingleton(() => GetBookingByIdUseCase(sl()));
  sl.registerLazySingleton(() => CancelBookingUseCase(sl()));
  sl.registerLazySingleton(() => GetOwnerBookingsUseCase(sl()));
  sl.registerLazySingleton(() => GetPendingBookingsUseCase(sl()));
  sl.registerLazySingleton(() => ApproveBookingUseCase(sl()));
  sl.registerLazySingleton(() => RejectBookingUseCase(sl()));

  // BLoC - Factory
  sl.registerFactory(
    () => BookingBloc(
      createBookingUseCase: sl(),
      getRenterBookingsUseCase: sl(),
      getBookingByIdUseCase: sl(),
      cancelBookingUseCase: sl(),
      getOwnerBookingsUseCase: sl(),
      getPendingBookingsUseCase: sl(),
      approveBookingUseCase: sl(),
      rejectBookingUseCase: sl(),
    ),
  );

  //============================================================================
  // FEATURES - NOTIFICATION
  //============================================================================

  // Data Sources
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(dioClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => GetUnreadCountUseCase(sl()));
  sl.registerLazySingleton(() => MarkAsReadUseCase(sl()));
  sl.registerLazySingleton(() => MarkAllAsReadUseCase(sl()));
  sl.registerLazySingleton(() => DeleteNotificationUseCase(sl()));
  sl.registerLazySingleton(() => RegisterFcmTokenUseCase(sl()));
  sl.registerLazySingleton(() => UnregisterFcmTokenUseCase(sl()));

  // BLoC - Factory
  sl.registerFactory(
    () => NotificationBloc(
      getNotificationsUseCase: sl(),
      getUnreadCountUseCase: sl(),
      markAsReadUseCase: sl(),
      markAllAsReadUseCase: sl(),
      deleteNotificationUseCase: sl(),
    ),
  );
}
