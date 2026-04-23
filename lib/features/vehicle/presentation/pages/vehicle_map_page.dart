import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as ll;

import '../../../../core/config/map_provider_config.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../bloc/vehicles_list_cubit.dart';
import '../widgets/nearby_vehicles_sheet.dart';

/// Full-screen map page showing nearby vehicles with interactive markers,
/// a radius slider, and a draggable bottom sheet listing vehicles.
///
/// Uses **OpenStreetMap tiles** (via [flutter_map]) — no Google API key on web.
/// On Android/iOS, [GoogleMap] is used only when [useGoogleMapWidget] is true
/// (see [map_provider_config.dart]).
class VehicleMapPage extends StatefulWidget {
  const VehicleMapPage({super.key});

  @override
  State<VehicleMapPage> createState() => _VehicleMapPageState();
}

class _VehicleMapPageState extends State<VehicleMapPage> {
  final LocationService _locationService = sl<LocationService>();
  gmaps.GoogleMapController? _googleMapController;
  final fm.MapController _osmMapController = fm.MapController();

  ll.LatLng? _userPosition;
  bool _isLoadingLocation = true;
  bool _permissionDenied = false;

  double _radiusKm = 5.0;

  List<VehicleEntity> _allFetchedVehicles = [];

  static const ll.LatLng _defaultCenter = ll.LatLng(10.7769, 106.7009);

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    _osmMapController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    final position = await _locationService.getCurrentPosition();

    if (!mounted) return;

    if (position != null) {
      setState(() {
        _userPosition = ll.LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });

      _loadNearby();
      _animateCameraToUser();
    } else {
      setState(() {
        _isLoadingLocation = false;
        _permissionDenied = true;
      });
    }
  }

  void _loadNearby() {
    if (_userPosition == null) return;
    context.read<VehicleListCubit>().loadNearbyVehicles(
          userLat: _userPosition!.latitude,
          userLng: _userPosition!.longitude,
          radiusKm: _radiusKm,
        );
  }

  void _animateCameraToUser() {
    final target = _userPosition ?? _defaultCenter;
    if (useGoogleMapWidget) {
      _googleMapController?.animateCamera(
        gmaps.CameraUpdate.newCameraPosition(
          gmaps.CameraPosition(
            target: gmaps.LatLng(target.latitude, target.longitude),
            zoom: 14,
          ),
        ),
      );
    } else {
      _osmMapController.move(target, 14);
    }
  }

  void _onRadiusChanged(double value) {
    setState(() => _radiusKm = value);
    if (_userPosition != null && _allFetchedVehicles.isNotEmpty) {
      context.read<VehicleListCubit>().updateRadius(
            _allFetchedVehicles,
            _radiusKm,
            _userPosition!.latitude,
            _userPosition!.longitude,
          );
    }
  }

  Set<gmaps.Marker> _buildGoogleMarkers(List<VehicleEntity> vehicles) {
    return vehicles.map((vehicle) {
      final isAvailable =
          vehicle.isAvailable && vehicle.status == VehicleStatus.available;
      return gmaps.Marker(
        markerId: gmaps.MarkerId(vehicle.id),
        position: gmaps.LatLng(vehicle.latitude!, vehicle.longitude!),
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
          isAvailable
              ? gmaps.BitmapDescriptor.hueGreen
              : gmaps.BitmapDescriptor.hueRed,
        ),
        infoWindow: gmaps.InfoWindow(
          title: vehicle.displayName,
          snippet: isAvailable
              ? '${vehicle.formattedPricePerHour} • Có sẵn'
              : 'Không khả dụng',
          onTap: () => context.push('/vehicle/${vehicle.id}'),
        ),
        onTap: () => context.push('/vehicle/${vehicle.id}'),
      );
    }).toSet();
  }

  Set<gmaps.Circle> _buildGoogleCircles() {
    if (_userPosition == null) return {};
    return {
      gmaps.Circle(
        circleId: const gmaps.CircleId('searchRadius'),
        center: gmaps.LatLng(_userPosition!.latitude, _userPosition!.longitude),
        radius: _radiusKm * 1000,
        fillColor: AppColors.primary.withOpacity(0.08),
        strokeColor: AppColors.primary.withOpacity(0.4),
        strokeWidth: 2,
      ),
    };
  }

  List<fm.Marker> _buildOsmVehicleMarkers(List<VehicleEntity> vehicles) {
    return vehicles.map((vehicle) {
      final isAvailable =
          vehicle.isAvailable && vehicle.status == VehicleStatus.available;
      return fm.Marker(
        point: ll.LatLng(vehicle.latitude!, vehicle.longitude!),
        width: 48,
        height: 48,
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () => context.push('/vehicle/${vehicle.id}'),
          child: Icon(
            Icons.location_on,
            size: 44,
            color: isAvailable ? Colors.green.shade700 : Colors.red.shade700,
            shadows: const [
              Shadow(
                blurRadius: 4,
                color: Colors.black26,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<fm.CircleMarker> _buildOsmRadiusCircles() {
    if (_userPosition == null) return [];
    return [
      fm.CircleMarker(
        point: _userPosition!,
        radius: _radiusKm * 1000,
        useRadiusInMeter: true,
        color: AppColors.primary.withOpacity(0.08),
        borderColor: AppColors.primary.withOpacity(0.45),
        borderStrokeWidth: 2,
      ),
    ];
  }

  Widget _buildOsmMap(List<VehicleEntity> vehicles) {
    final center = _userPosition ?? _defaultCenter;
    final userMarkers = <fm.Marker>[];
    if (_userPosition != null) {
      userMarkers.add(
        fm.Marker(
          point: _userPosition!,
          width: 36,
          height: 36,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: const Icon(Icons.person_pin_circle,
                color: AppColors.primary, size: 28),
          ),
        ),
      );
    }

    return fm.FlutterMap(
      mapController: _osmMapController,
      options: fm.MapOptions(
        initialCenter: center,
        initialZoom: 14,
        minZoom: 3,
        maxZoom: 19,
        onMapReady: _animateCameraToUser,
      ),
      children: [
        fm.TileLayer(
          urlTemplate: kOsmTileUrlTemplate,
          subdomains: kOsmSubdomains,
          userAgentPackageName: 'com.example.fe_capstone_project',
        ),
        fm.CircleLayer(circles: _buildOsmRadiusCircles()),
        fm.MarkerLayer(markers: _buildOsmVehicleMarkers(vehicles)),
        if (userMarkers.isNotEmpty) fm.MarkerLayer(markers: userMarkers),
      ],
    );
  }

  Widget _buildGoogleMap(List<VehicleEntity> vehicles) {
    final center = _userPosition ?? _defaultCenter;
    return gmaps.GoogleMap(
      initialCameraPosition: gmaps.CameraPosition(
        target: gmaps.LatLng(center.latitude, center.longitude),
        zoom: 14,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      markers: _buildGoogleMarkers(vehicles),
      circles: _buildGoogleCircles(),
      onMapCreated: (controller) {
        _googleMapController = controller;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocConsumer<VehicleListCubit, VehicleListState>(
            listener: (context, state) {
              if (state is VehicleListLoaded) {
                if (_allFetchedVehicles.isEmpty ||
                    state.vehicles.length > _allFetchedVehicles.length) {
                  _allFetchedVehicles = List.from(state.vehicles);
                }
              }
            },
            builder: (context, state) {
              final vehicles =
                  state is VehicleListLoaded ? state.vehicles : <VehicleEntity>[];
              return useGoogleMapWidget
                  ? _buildGoogleMap(vehicles)
                  : _buildOsmMap(vehicles);
            },
          ),

          if (_isLoadingLocation)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Đang lấy vị trí của bạn...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

          if (_permissionDenied && !_isLoadingLocation)
            Container(
              color: Colors.black45,
              child: Center(
                child: Card(
                  margin: const EdgeInsets.all(32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_off,
                            size: 64, color: AppColors.warning),
                        const SizedBox(height: 16),
                        Text(
                          'Cần quyền truy cập vị trí',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ứng dụng cần vị trí của bạn để tìm xe gần nhất.',
                          style: GoogleFonts.poppins(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isLoadingLocation = true;
                              _permissionDenied = false;
                            });
                            _initLocation();
                          },
                          icon: const Icon(Icons.my_location),
                          label: const Text('Cấp quyền'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Xe gần bạn',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (!useGoogleMapWidget)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              'Bản đồ OpenStreetMap (sandbox)',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      _allFetchedVehicles.clear();
                      _loadNearby();
                    },
                  ),
                ],
              ),
            ),
          ),

          if (!_permissionDenied && !_isLoadingLocation)
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).size.height * 0.32 + 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bán kính tìm kiếm',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_radiusKm.toStringAsFixed(0)} km',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: AppColors.primary.withOpacity(0.2),
                        thumbColor: AppColors.primary,
                        overlayColor: AppColors.primary.withOpacity(0.1),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: _radiusKm,
                        min: 1,
                        max: 20,
                        divisions: 19,
                        onChanged: _onRadiusChanged,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (!_permissionDenied && !_isLoadingLocation)
            DraggableScrollableSheet(
              initialChildSize: 0.30,
              minChildSize: 0.12,
              maxChildSize: 0.75,
              builder: (context, scrollController) {
                return NearbyVehiclesSheet(
                  scrollController: scrollController,
                  radiusKm: _radiusKm,
                );
              },
            ),

          if (!_permissionDenied && !_isLoadingLocation)
            Positioned(
              right: 16,
              bottom: MediaQuery.of(context).size.height * 0.32 + 80,
              child: FloatingActionButton.small(
                heroTag: 'my_location_fab',
                backgroundColor: Colors.white,
                onPressed: _animateCameraToUser,
                child: const Icon(Icons.my_location, color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}
