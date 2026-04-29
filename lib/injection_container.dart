import 'package:get_it/get_it.dart';

// Core
import 'core/network/dio_client.dart';
import 'core/storage/storage_service.dart';
import 'core/services/upload_service.dart';
import 'core/services/socket_service.dart';
import 'core/services/fcm_service.dart';
import 'core/services/geocoding_service.dart';
import 'core/services/location_service.dart';

// Trip Feature
import 'features/trip/data/datasources/trip_remote_datasource.dart';
import 'features/trip/data/repositories/trip_repository_impl.dart';
import 'features/trip/domain/repositories/trip_repository.dart';
import 'features/trip/domain/usecases/trip_usecases.dart';
import 'features/trip/presentation/bloc/trip_bloc.dart';

// Payment Feature
import 'features/payment/data/datasources/payment_remote_datasource.dart';
import 'features/payment/data/repositories/payment_repository_impl.dart';
import 'features/payment/domain/repositories/payment_repository.dart';
import 'features/payment/domain/usecases/payment_usecases.dart';
import 'features/payment/presentation/bloc/payment_bloc.dart';

// Review Feature
import 'features/review/data/datasources/review_remote_datasource.dart';
import 'features/review/data/repositories/review_repository_impl.dart';
import 'features/review/domain/repositories/review_repository.dart';
import 'features/review/domain/usecases/review_usecases.dart';
import 'features/review/presentation/bloc/review_bloc.dart';

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
import 'features/owner_vehicle/domain/usecases/delete_vehicle_usecase.dart';
import 'features/owner_vehicle/domain/usecases/get_my_vehicles_usecase.dart';
import 'features/owner_vehicle/domain/usecases/get_vehicle_by_id_usecase.dart';
import 'features/owner_vehicle/domain/usecases/register_vehicle_usecase.dart';
import 'features/owner_vehicle/domain/usecases/toggle_availability_usecase.dart';
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
import 'features/vehicle/domain/usecases/get_nearby_vehicles.dart';
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

// Settings Feature
import 'features/settings/data/privacy_remote_data_source.dart';

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

  // Location Service - Singleton
  sl.registerLazySingleton<LocationService>(() => LocationService());

  // Geocoding Service - Singleton (Nominatim / OSM, no API key required)
  sl.registerLazySingleton<GeocodingService>(() => GeocodingService());

  // Privacy API - Singleton (depends on DioClient)
  sl.registerLazySingleton<PrivacyRemoteDataSource>(
    () => PrivacyRemoteDataSourceImpl(dioClient: sl()),
  );

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
  sl.registerLazySingleton(() => ToggleAvailabilityUseCase(sl()));
  sl.registerLazySingleton(() => DeleteVehicleUseCase(sl()));

  // BLoC - Factory
  sl.registerFactory(
    () => OwnerVehicleBloc(
      getMyVehiclesUseCase: sl(),
      registerVehicleUseCase: sl(),
      updateVehicleUseCase: sl(),
      getVehicleByIdUseCase: sl(),
      toggleAvailabilityUseCase: sl(),
      deleteVehicleUseCase: sl(),
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
  sl.registerLazySingleton(() => GetNearbyVehicles(sl()));
  sl.registerLazySingleton(() => GetVehicleById(sl()));

  // Cubit - Factory
  sl.registerFactory(
    () => VehicleListCubit(getAvailableVehicles: sl(), getNearbyVehicles: sl()),
  );
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
  // FEATURES - TRIP
  //============================================================================

  // Data Sources
  sl.registerLazySingleton<TripRemoteDataSource>(
    () => TripRemoteDataSourceImpl(dioClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<TripRepository>(
    () => TripRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => StartTripUseCase(sl()));
  sl.registerLazySingleton(() => EndTripUseCase(sl()));
  sl.registerLazySingleton(() => GetActiveTripUseCase(sl()));
  sl.registerLazySingleton(() => GetTripHistoryUseCase(sl()));
  sl.registerLazySingleton(() => GetTripByIdUseCase(sl()));

  // BLoC - Factory
  sl.registerFactory(
    () => TripBloc(
      startTrip: sl(),
      endTrip: sl(),
      getActiveTrip: sl(),
      getTripHistory: sl(),
      getTripById: sl(),
    ),
  );

  //============================================================================
  // FEATURES - PAYMENT
  //============================================================================

  // Data Sources
  sl.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(dioClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => CreatePaymentUseCase(sl()));
  sl.registerLazySingleton(() => GetPaymentByBookingUseCase(sl()));
  sl.registerLazySingleton(() => GetPaymentByIdUseCase(sl()));
  sl.registerLazySingleton(() => SimulatePaymentSuccessUseCase(sl()));
  sl.registerLazySingleton(() => InitiatePayOSUseCase(sl()));
  sl.registerLazySingleton(() => InitiateMoMoUseCase(sl()));
  sl.registerLazySingleton(() => RefundPaymentUseCase(sl()));
  sl.registerLazySingleton(() => GetOwnerEarningsUseCase(sl()));

  // BLoC - Factory
  sl.registerFactory(
    () => PaymentBloc(
      createPayment: sl(),
      getPaymentByBooking: sl(),
      getPaymentById: sl(),
      simulateSuccess: sl(),
      initiatePayOS: sl(),
      initiateMoMo: sl(),
      refundPayment: sl(),
      getOwnerEarnings: sl(),
    ),
  );

  //============================================================================
  // FEATURES - REVIEW
  //============================================================================

  // Data Sources
  sl.registerLazySingleton<ReviewRemoteDataSource>(
    () => ReviewRemoteDataSourceImpl(dioClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => CreateReviewUseCase(sl()));
  sl.registerLazySingleton(() => GetVehicleReviewsUseCase(sl()));
  sl.registerLazySingleton(() => GetMyReviewsUseCase(sl()));
  sl.registerLazySingleton(() => GetTrustScoreBreakdownUseCase(sl()));

  // BLoC - Factory
  sl.registerFactory(
    () => ReviewBloc(
      createReview: sl(),
      getVehicleReviews: sl(),
      getMyReviews: sl(),
      getTrustScore: sl(),
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
