/// API configuration constants
class ApiConstants {
  ApiConstants._();

  /// Base URL for the API
  /// Use 'http://10.0.2.2:3000' for Android emulator
  /// Use 'http://localhost:3000' for iOS simulator or web
  /// Override locally with:
  ///   flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://p2p-emrs.onrender.com',
  );

  /// Connection timeout in milliseconds
  static const int connectTimeout = 30000;

  /// Receive timeout in milliseconds
  static const int receiveTimeout = 30000;

  /// Auth endpoints
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authProfile = '/auth/profile';
  static const String authSensitiveOtp = '/auth/request-sensitive-otp';

  /// Vehicle endpoints
  static const String vehicles = '/vehicles';
  static const String myVehicles = '/vehicles/my-vehicles';
  static const String availableVehicles = '/vehicles/available';
  static String vehicleById(String id) => '/vehicles/$id';
  static String toggleVehicleAvailability(String id) =>
      '/vehicles/$id/toggle-availability';
  static String vehicleAvailability(String id) => '/vehicles/$id/availability';
  static String vehicleAvailabilitySummary(String id) =>
      '/vehicles/$id/availability-summary';
  static String vehicleAvailabilityWindow(String id, String windowId) =>
      '/vehicles/$id/availability/$windowId';

  /// Booking endpoints
  static const String bookings = '/bookings';
  static String bookingCancellationPreview(String id) =>
      '/bookings/$id/cancellation-preview';
  static String vehicleSchedule(String vehicleId) =>
      '/bookings/vehicle/$vehicleId/schedule';

  /// Trip endpoints
  static const String trips = '/trips';
  static const String startTrip = '/trips/start';
  static const String activeTrip = '/trips/active';
  static const String tripHistory = '/trips/history';
  static String endTrip(String id) => '/trips/$id/end';
  static String tripById(String id) => '/trips/$id';

  /// Handover endpoints
  static const String handoverCheckIn = '/handover/check-in';
  static const String handoverCheckOut = '/handover/check-out';
  static String handoverByBooking(String bookingId) => '/handover/$bookingId';
  static String confirmHandover(String id) => '/handover/$id/confirm';

  /// Payment endpoints
  static const String payments = '/payments';
  static const String paymentByBooking = '/payments/by-booking';
  static String paymentById(String id) => '/payments/$id';
  static String simulatePaymentSuccess(String id) =>
      '/payments/$id/simulate-success';
  static String initiatePayOS(String id) => '/payments/$id/initiate-payos';
  static String initiateMoMo(String id) => '/payments/$id/initiate-momo';
  static String refundPayment(String id) => '/payments/$id/refund';

  /// Financial endpoints
  static String financialByBooking(String bookingId) =>
      '/financial/bookings/$bookingId';
  static String financialChargesByBooking(String bookingId) =>
      '/financial/bookings/$bookingId/charges';
  static String disputeFinancialCharge(String chargeId) =>
      '/financial/charges/$chargeId/dispute';

  /// Incident endpoints
  static const String incidents = '/incidents';
  static String incidentsByBooking(String bookingId) =>
      '/incidents/bookings/$bookingId';
  static String claimSummaryByBooking(String bookingId) =>
      '/incidents/bookings/$bookingId/claim-summary';

  /// Privacy endpoints
  static const String privacyExport = '/privacy/export';
  static const String privacyDeleteRequest = '/privacy/delete-request';
  static const String privacyRequests = '/privacy/requests';

  /// Review endpoints
  static const String reviews = '/reviews';
  static const String myReviews = '/reviews/my-reviews';
  static const String trustScore = '/reviews/trust-score';
  static String userTrustScore(String userId) => '/reviews/trust-score/$userId';
  static String bookingReviewStatus(String bookingId) =>
      '/reviews/bookings/$bookingId/status';
  static String vehicleReviews(String vehicleId) =>
      '/reviews/vehicle/$vehicleId';

  /// Upload endpoints
  static const String uploadVehicleImage = '/upload/vehicle-image';
  static const String uploadVehicleImages = '/upload/vehicle-images';
  static const String uploadLicense = '/upload/license';
  static const String uploadKyc = '/upload/kyc';
  static const String uploadHandover = '/upload/handover';
  static const String uploadIncident = '/upload/incident';

  /// KYC endpoints
  static const String kycSubmit = '/kyc/submit';
  static const String kycStatus = '/kyc/status';

  static const String authBecomeOwner = '/auth/become-owner';
}

/// Storage keys
class StorageKeys {
  StorageKeys._();

  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String themeMode = 'theme_mode';
  static const String localeCode = 'locale_code';
  static const String dataSaverEnabled = 'data_saver_enabled';
}
