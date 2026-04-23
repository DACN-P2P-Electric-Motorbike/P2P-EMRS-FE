# Maps: OpenStreetMap (default) vs Google Maps

## Default (sandbox / no API key)

The app uses **[flutter_map](https://pub.dev/packages/flutter_map)** with **Carto OSM** raster tiles. No billing, no Google Cloud project. Suitable for development and demos.

- **Web (Chrome, PWA):** always uses OSM — Google Maps is **not** used on web (avoids “Oops! Something went wrong” when the JS API key is missing or denied).
- **Android / iOS:** OSM by default; set `USE_GOOGLE_MAPS=true` **and** valid native API keys to use Google’s SDK instead.
- Location still comes from GPS (`geolocator`); only the **map tiles** differ.

## Enable Google Maps (production)

1. Create a Google Cloud project, enable billing, and enable **Maps SDK for Android**, **Maps SDK for iOS**, and **Maps JavaScript API** (for web).
2. Run with a compile-time flag:

   ```bash
   flutter run -d chrome --dart-define=USE_GOOGLE_MAPS=true
   ```

3. **Web:** In `web/index.html`, uncomment the Google Maps script and replace `YOUR_KEY` with your real key.
4. **Android:** Add the API key in `AndroidManifest` / Gradle as per [Google’s Flutter guide](https://pub.dev/packages/google_maps_flutter).
5. **iOS:** Set `GMSServices.provideAPIKey("...")` in `ios/Runner/AppDelegate.swift`.

## Configuration

| Constant | Location | Default |
|----------|----------|---------|
| `USE_GOOGLE_MAPS` | `dart-define` | `false` |

Implementation: `lib/core/config/map_provider_config.dart`.

## Tile usage

Free OSM/Carto tiles are fine for moderate dev/demo traffic. For production scale, consider [MapTiler](https://www.maptiler.com/), self-hosted tiles, or Google Maps.
