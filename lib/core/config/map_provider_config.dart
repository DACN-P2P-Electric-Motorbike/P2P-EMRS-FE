import 'package:flutter/foundation.dart';

/// Map backend selection (sandbox vs production Google Maps).
///
/// **Default: OpenStreetMap via `flutter_map`** — no API key, works offline from
/// key/billing issues. Good for dev, demo, and CI.
///
/// **Enable Google Maps** on **Android/iOS only** when your Cloud project has
/// billing + native SDK keys configured:
/// ```bash
/// flutter run --dart-define=USE_GOOGLE_MAPS=true
/// ```
///
/// **Web (Chrome / PWA)** always uses OpenStreetMap ([flutter_map]). Google’s
/// web widget needs a valid Maps JavaScript API key in [web/index.html]; without
/// it the map shows *"Oops! Something went wrong."* — so we never use Google Maps
/// on web here. You can still use the same UX (markers, radius, sheet).
///
/// Android: API key in `AndroidManifest` / Gradle.
/// iOS: `GMSServices.provideAPIKey(...)` in `AppDelegate.swift`.
const bool kUseGoogleMaps = bool.fromEnvironment(
  'USE_GOOGLE_MAPS',
  defaultValue: false,
);

/// Whether to build [GoogleMap] vs [flutter_map].
///
/// - **Web:** always `false` (use OSM; Google JS API needs a valid key in HTML).
/// - **Desktop** (macOS/Windows/Linux): always `false` (plugin targets mobile).
/// - **Android / iOS:** `true` only when [kUseGoogleMaps] is `true` and native
///   API keys are configured — otherwise you still see OSM if `USE_GOOGLE_MAPS`
///   is unset/false.
bool get useGoogleMapWidget {
  if (!kUseGoogleMaps) return false;
  if (kIsWeb) return false;
  if (defaultTargetPlatform != TargetPlatform.android &&
      defaultTargetPlatform != TargetPlatform.iOS) {
    return false;
  }
  return true;
}

/// Free OSM tile server (Carto light). No key required; acceptable for dev/demo.
/// For heavy production traffic, host your own tiles or use a commercial provider.
const String kOsmTileUrlTemplate =
    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';

const List<String> kOsmSubdomains = ['a', 'b', 'c', 'd'];
