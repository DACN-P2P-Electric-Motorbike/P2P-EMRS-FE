import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../config/map_provider_config.dart';
import '../services/geocoding_service.dart';
import '../theme/app_theme.dart';

/// A full-screen location picker built on OpenStreetMap (flutter_map).
///
/// UX flow:
/// 1. Map opens at [initialLatLng] (or Ho Chi Minh City default).
/// 2. A crosshair pin stays fixed in the screen centre; the map pans under it.
/// 3. The user can type an address in the search bar → map animates there.
/// 4. As the map stops moving the address is reverse-geocoded and shown below.
/// 5. Tapping "Xác nhận vị trí" pops with a [LocationPickerResult].
///
/// Usage:
/// ```dart
/// final result = await Navigator.push<LocationPickerResult>(
///   context,
///   MaterialPageRoute(builder: (_) => LocationPickerPage(
///     initialAddress: vehicle.address,
///     initialLatLng: vehicle.latLng,
///   )),
/// );
/// if (result != null) { /* use result.latitude / .longitude / .address */ }
/// ```
class LocationPickerPage extends StatefulWidget {
  final String? initialAddress;
  final LatLng? initialLatLng;

  const LocationPickerPage({
    super.key,
    this.initialAddress,
    this.initialLatLng,
  });

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  // Default to Ho Chi Minh City centre
  static const LatLng _defaultCenter = LatLng(10.7769, 106.7009);
  static const double _defaultZoom = 14.0;

  final MapController _mapController = MapController();
  final GeocodingService _geocodingService = GeocodingService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  LatLng _centerLatLng = _defaultCenter;
  String _currentAddress = '';
  bool _isSearching = false;
  bool _isReverseGeocoding = false;
  String? _searchError;

  Timer? _reverseGeocodeTimer;

  @override
  void initState() {
    super.initState();

    // Set initial position
    if (widget.initialLatLng != null) {
      _centerLatLng = widget.initialLatLng!;
    }

    if (widget.initialAddress != null && widget.initialAddress!.isNotEmpty) {
      _searchController.text = widget.initialAddress!;
      _currentAddress = widget.initialAddress!;
      // If we have an address but no coords, geocode it
      if (widget.initialLatLng == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _geocodeAndMove(widget.initialAddress!);
        });
      }
    } else {
      // No initial info: reverse-geocode the default centre
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scheduleReverseGeocode(_centerLatLng);
      });
    }
  }

  @override
  void dispose() {
    _reverseGeocodeTimer?.cancel();
    _mapController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ── Geocoding helpers ───────────────────────────────────────────────────────

  Future<void> _geocodeAndMove(String address) async {
    if (address.trim().isEmpty) return;
    setState(() {
      _isSearching = true;
      _searchError = null;
    });
    final latLng = await _geocodingService.geocodeAddress(address);
    if (!mounted) return;
    if (latLng == null) {
      setState(() {
        _isSearching = false;
        _searchError = 'Không tìm thấy địa chỉ. Hãy thử cụ thể hơn.';
      });
      return;
    }
    setState(() {
      _isSearching = false;
      _centerLatLng = latLng;
    });
    _mapController.move(latLng, _defaultZoom);
    _searchFocus.unfocus();
    _scheduleReverseGeocode(latLng);
  }

  void _scheduleReverseGeocode(LatLng latLng) {
    _reverseGeocodeTimer?.cancel();
    _reverseGeocodeTimer = Timer(const Duration(milliseconds: 600), () async {
      if (!mounted) return;
      setState(() => _isReverseGeocoding = true);
      final address = await _geocodingService.reverseGeocode(
        latLng.latitude,
        latLng.longitude,
      );
      if (!mounted) return;
      setState(() {
        _isReverseGeocoding = false;
        _currentAddress = address ?? '';
      });
    });
  }

  void _onMapPositionChanged(MapCamera camera, bool hasGesture) {
    if (!hasGesture) return;
    final center = camera.center;
    setState(() => _centerLatLng = center);
    _scheduleReverseGeocode(center);
  }

  void _confirm() {
    if (_currentAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang tải địa chỉ, vui lòng đợi...')),
      );
      return;
    }
    Navigator.of(context).pop(
      LocationPickerResult(
        latitude: _centerLatLng.latitude,
        longitude: _centerLatLng.longitude,
        address: _currentAddress,
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Chọn vị trí',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ── Map ─────────────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _centerLatLng,
              initialZoom: _defaultZoom,
              onPositionChanged: _onMapPositionChanged,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: kOsmTileUrlTemplate,
                subdomains: kOsmSubdomains,
                userAgentPackageName: 'com.dreamride.app',
              ),
            ],
          ),

          // ── Crosshair pin (always centred) ──────────────────────────────────
          const Center(child: _CrosshairPin()),

          // ── Search bar (top) ────────────────────────────────────────────────
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: _SearchBar(
              controller: _searchController,
              focusNode: _searchFocus,
              isSearching: _isSearching,
              error: _searchError,
              onSubmitted: _geocodeAndMove,
              onClear: () {
                _searchController.clear();
                setState(() => _searchError = null);
              },
            ),
          ),

          // ── Address card + confirm button (bottom) ──────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomCard(
              address: _currentAddress,
              isLoading: _isReverseGeocoding,
              onConfirm: _confirm,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _CrosshairPin extends StatelessWidget {
  const _CrosshairPin();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.location_on, color: Colors.white, size: 20),
          ),
          // Pin stem
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Shadow dot
          Container(
            width: 10,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSearching;
  final String? error;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.isSearching,
    required this.error,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(14),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            textInputAction: TextInputAction.search,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Nhập địa chỉ để tìm kiếm...',
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[400],
              ),
              prefixIcon: isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Icon(Icons.search, color: Colors.grey),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: onClear,
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onSubmitted: onSubmitted,
          ),
        ),
        if (error != null)
          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              error!,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class _BottomCard extends StatelessWidget {
  final String address;
  final bool isLoading;
  final VoidCallback onConfirm;

  const _BottomCard({
    required this.address,
    required this.isLoading,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, -4)),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(
            'Vị trí đã chọn',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          if (isLoading)
            Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 10),
                Text(
                  'Đang tải địa chỉ...',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address.isEmpty ? 'Di chuyển bản đồ để chọn vị trí' : address,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: address.isEmpty
                          ? AppColors.textMuted
                          : AppColors.textPrimary,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading || address.isEmpty ? null : onConfirm,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(
                'Xác nhận vị trí',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
