import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

String vehicleLabel(BuildContext context, String key) {
  return AppLocalizations.of(context).t(key);
}

String vehicleStatusLabel(BuildContext context, String apiValue) {
  switch (apiValue.toUpperCase()) {
    case 'AVAILABLE':
      return vehicleLabel(context, 'vehicleStatusAvailable');
    case 'RENTED':
      return vehicleLabel(context, 'vehicleStatusRented');
    case 'MAINTENANCE':
      return vehicleLabel(context, 'vehicleStatusMaintenance');
    case 'PENDING_APPROVAL':
      return vehicleLabel(context, 'vehicleStatusPending');
    case 'REJECTED':
      return vehicleLabel(context, 'vehicleStatusRejected');
    case 'LOCKED':
      return vehicleLabel(context, 'vehicleStatusLocked');
    case 'UNAVAILABLE':
      return vehicleLabel(context, 'vehicleStatusUnavailable');
    default:
      return vehicleLabel(context, 'vehicleStatusPending');
  }
}

String vehicleBrandLabel(BuildContext context, String apiValue) {
  switch (apiValue.toUpperCase()) {
    case 'VINFAST':
      return 'VinFast';
    case 'PEGA':
      return 'Pega';
    case 'YADEA':
      return 'Yadea';
    default:
      return vehicleLabel(context, 'vehicleOther');
  }
}

String vehicleTypeLabel(BuildContext context, String apiValue) {
  switch (apiValue.toUpperCase()) {
    case 'VINFAST_KLARA':
      return 'VinFast Klara';
    case 'VINFAST_FELIZ':
      return 'VinFast Feliz';
    case 'VINFAST_VENTO':
      return 'VinFast Vento';
    case 'ELECTRIC_SCOOTER':
      return vehicleLabel(context, 'vehicleTypeElectricScooter');
    case 'ELECTRIC_MOTORCYCLE':
      return vehicleLabel(context, 'vehicleTypeElectricMotorcycle');
    case 'ELECTRIC_BIKE':
      return vehicleLabel(context, 'vehicleTypeElectricBike');
    default:
      return vehicleLabel(context, 'vehicleOther');
  }
}

String vehicleFeatureLabel(BuildContext context, String apiValue) {
  switch (apiValue.toUpperCase()) {
    case 'REPLACEABLE_BATTERY':
      return vehicleLabel(context, 'vehicleFeatureReplaceableBattery');
    case 'FAST_CHARGING':
      return vehicleLabel(context, 'vehicleFeatureFastCharging');
    case 'DIFFICULT_TERRAIN':
      return vehicleLabel(context, 'vehicleFeatureDifficultTerrain');
    case 'GPS_TRACKING':
      return vehicleLabel(context, 'vehicleFeatureGpsTracking');
    case 'ANTI_THEFT':
      return vehicleLabel(context, 'vehicleFeatureAntiTheft');
    default:
      return apiValue;
  }
}
