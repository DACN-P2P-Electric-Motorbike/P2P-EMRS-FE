/// App-wide constants
class AppConstants {
  AppConstants._();

  /// App name
  static const String appName = 'Dream Ride';

  /// Roles
  static const String roleRenter = 'RENTER';
  static const String roleOwner = 'OWNER';
  static const String roleAdmin = 'ADMIN';

  /// Storage keys for local preferences
  static const String keyActiveRole = 'active_role';
  static const String keyOnboardingComplete = 'onboarding_complete';

  /// Platform fees
  static const double platformFeeRate = 0.15; // 15%

  /// Trust score
  static const double defaultTrustScore = 100.0;
  static const double minTrustScoreForBooking = 30.0;

  /// Search defaults
  static const double defaultSearchRadius = 5.0; // km
  static const int defaultPageSize = 20;

  /// Map defaults
  static const double defaultLatitude = 10.762622; // HCMC
  static const double defaultLongitude = 106.660172;
  static const double defaultZoom = 14.0;

  /// Booking time windows
  static const int minBookingHours = 1;
  static const int maxBookingDays = 30;

  /// Battery levels
  static const int minBatteryForRent = 20;
  static const int warningBatteryLevel = 30;

  /// Image upload
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
}

/// API response status
enum ApiStatus { initial, loading, success, error }

/// Helper class for role checking
class UserRoles {
  UserRoles._();

  /// Check if roles list contains a specific role
  static bool hasRole(List<String> roles, String role) {
    return roles.any((r) => r.toUpperCase() == role.toUpperCase());
  }

  /// Check if user is renter
  static bool isRenter(List<String> roles) {
    return hasRole(roles, AppConstants.roleRenter);
  }

  /// Check if user is owner
  static bool isOwner(List<String> roles) {
    return hasRole(roles, AppConstants.roleOwner);
  }

  /// Check if user is admin
  static bool isAdmin(List<String> roles) {
    return hasRole(roles, AppConstants.roleAdmin);
  }

  /// Check if user has multiple roles
  static bool hasMultipleRoles(List<String> roles) {
    return roles.length > 1;
  }

  /// Get primary role (first in list)
  static String getPrimaryRole(List<String> roles) {
    return roles.isNotEmpty ? roles.first : AppConstants.roleRenter;
  }
}
