import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../../review/presentation/pages/create_review_page.dart';
import '../../domain/entities/trip_entity.dart';
import '../bloc/trip_bloc.dart';
import '../bloc/trip_event.dart';
import '../bloc/trip_state.dart';

/// Active trip tracking page
class ActiveTripPage extends StatelessWidget {
  final String tripId;
  final String bookingId;

  const ActiveTripPage({
    super.key,
    required this.tripId,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<TripBloc>()..add(LoadTripByIdEvent(tripId)),
      child: _ActiveTripView(tripId: tripId),
    );
  }
}

class _ActiveTripView extends StatefulWidget {
  final String tripId;

  const _ActiveTripView({required this.tripId});

  @override
  State<_ActiveTripView> createState() => _ActiveTripViewState();
}

class _ActiveTripViewState extends State<_ActiveTripView> {
  Timer? _timer;
  Timer? _gpsTimer;
  Duration _elapsed = Duration.zero;
  DateTime? _startedAt;

  /// Live distance in km computed from start coords → current GPS position.
  double _liveDistanceKm = 0.0;
  double? _startLat;
  double? _startLng;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_startedAt != null) {
        setState(() {
          _elapsed = DateTime.now().difference(_startedAt!);
        });
      }
    });
  }

  /// Start polling GPS every 30 seconds to update live distance.
  void _startGpsPolling() {
    if (_gpsTimer != null) return; // already running
    _updateLiveDistance(); // immediate first poll
    _gpsTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _updateLiveDistance();
    });
  }

  Future<void> _updateLiveDistance() async {
    if (_startLat == null || _startLng == null) return;
    try {
      final position = await sl<LocationService>().getCurrentPosition();
      if (position != null && mounted) {
        final distanceMeters = sl<LocationService>().distanceBetween(
          _startLat!,
          _startLng!,
          position.latitude,
          position.longitude,
        );
        setState(() {
          _liveDistanceKm = distanceMeters / 1000.0;
        });
      }
    } catch (_) {
      // GPS unavailable — keep last known distance
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _gpsTimer?.cancel();
    super.dispose();
  }

  String _formatElapsed(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: Text(
          'Chuyến đi đang diễn ra',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<TripBloc, TripState>(
        listener: (context, state) {
          if (state is TripLoaded && state.trip.startedAt != null) {
            setState(() {
              _startedAt = state.trip.startedAt;
              _elapsed = DateTime.now().difference(_startedAt!);
              _startLat = state.trip.startLatitude;
              _startLng = state.trip.startLongitude;
            });
            // Begin GPS polling for live distance once we know the start coords
            _startGpsPolling();
          }
          // TripEnded: stay on page to show the summary (builder handles it)
          if (state is TripFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TripLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          if (state is TripLoaded) {
            return _buildContent(context, state.trip);
          }
          if (state is TripEnded) {
            return _buildCompletedView(context, state.trip);
          }
          if (state is TripFailure) {
            return Center(
              child: Text(
                state.message,
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, TripEntity trip) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Live timer
          _buildTimerCard(),
          const SizedBox(height: 24),

          // Trip stats
          _buildStatsRow(trip),
          const SizedBox(height: 24),

          // Trip info
          _buildTripInfo(trip),
          const SizedBox(height: 32),

          // Battery indicator
          if (trip.startBattery != null) _buildBatteryCard(trip.startBattery!),
          const SizedBox(height: 32),

          // End trip button
          _buildEndTripButton(context, trip),
        ],
      ),
    );
  }

  Widget _buildTimerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00D2FF), Color(0xFF3A7BD5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            'Thời gian di chuyển',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _formatElapsed(_elapsed),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Đang di chuyển',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(TripEntity trip) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.route,
            label: 'Quãng đường',
            value: _liveDistanceKm > 0
                ? '${_liveDistanceKm.toStringAsFixed(1)} km'
                : trip.formattedDistance,
            color: const Color(0xFF00D2FF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.speed,
            label: 'Thời gian',
            value: _formatElapsed(_elapsed),
            color: const Color(0xFF9C27B0),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripInfo(TripEntity trip) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin chuyến đi',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (trip.startedAt != null)
            _buildInfoRow(
              Icons.play_circle_outline,
              'Bắt đầu',
              DateFormat('HH:mm - dd/MM/yyyy').format(trip.startedAt!),
            ),
          if (trip.startAddress != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.location_on_outlined,
              'Vị trí xuất phát',
              trip.startAddress!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBatteryCard(double battery) {
    final color = battery > 50
        ? AppColors.success
        : battery > 20
        ? AppColors.warning
        : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.battery_charging_full, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                'Pin lúc xuất phát: ${battery.toStringAsFixed(0)}%',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: battery / 100,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white38, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEndTripButton(BuildContext context, TripEntity trip) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showEndTripDialog(context, trip),
        icon: const Icon(Icons.stop_circle_outlined),
        label: Text(
          'Kết thúc chuyến đi',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _showEndTripDialog(BuildContext context, TripEntity trip) {
    bool hasIssues = false;
    final issueController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Kết thúc chuyến đi',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xác nhận kết thúc chuyến đi?',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(
                  'Có sự cố?',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                value: hasIssues,
                onChanged: (val) => setDialogState(() => hasIssues = val),
                contentPadding: EdgeInsets.zero,
              ),
              if (hasIssues) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: issueController,
                  decoration: InputDecoration(
                    hintText: 'Mô tả sự cố...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  maxLines: 2,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Quay lại'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                // Collect end-point GPS for distance calculation
                double? endLat;
                double? endLng;
                String? endAddress;
                try {
                  final position =
                      await sl<LocationService>().getCurrentPosition();
                  if (position != null) {
                    endLat = position.latitude;
                    endLng = position.longitude;
                    endAddress =
                        '${position.latitude.toStringAsFixed(5)}, '
                        '${position.longitude.toStringAsFixed(5)}';
                  }
                } catch (_) {
                  // GPS unavailable — backend will handle null gracefully
                }

                if (!context.mounted) return;
                context.read<TripBloc>().add(
                  EndTripEvent(
                    tripId: trip.id,
                    endLatitude: endLat,
                    endLongitude: endLng,
                    endAddress: endAddress,
                    hasIssues: hasIssues,
                    issueDescription:
                        hasIssues && issueController.text.isNotEmpty
                            ? issueController.text.trim()
                            : null,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('Kết thúc'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedView(BuildContext context, TripEntity trip) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Success icon
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.success.withOpacity(0.4), width: 2),
            ),
            child: Icon(Icons.check_circle_rounded, color: AppColors.success, size: 56),
          ),
          const SizedBox(height: 20),

          Text(
            'Chuyến đi hoàn thành!',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Cảm ơn bạn đã sử dụng dịch vụ',
            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
          ),

          const SizedBox(height: 28),

          // Trip metrics card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildMetric(
                        icon: Icons.route_rounded,
                        label: 'Quãng đường',
                        value: trip.formattedDistance,
                        color: const Color(0xFF00D2FF),
                      ),
                    ),
                    Container(width: 1, height: 56, color: Colors.white12),
                    Expanded(
                      child: _buildMetric(
                        icon: Icons.timer_rounded,
                        label: 'Thời gian',
                        value: _formatElapsed(_elapsed),
                        color: const Color(0xFF9C27B0),
                      ),
                    ),
                  ],
                ),
                if (trip.startBattery != null && trip.endBattery != null) ...[
                  const Divider(color: Colors.white12, height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetric(
                          icon: Icons.battery_charging_full_rounded,
                          label: 'Pin ban đầu',
                          value: '${trip.startBattery!.toStringAsFixed(0)}%',
                          color: AppColors.success,
                        ),
                      ),
                      Container(width: 1, height: 56, color: Colors.white12),
                      Expanded(
                        child: _buildMetric(
                          icon: Icons.battery_1_bar_rounded,
                          label: 'Pin còn lại',
                          value: '${trip.endBattery!.toStringAsFixed(0)}%',
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          if (trip.hasIssues) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Có sự cố đã được báo cáo trong chuyến đi này.',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Review CTA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateReviewPage(
                    vehicleId: trip.vehicleId,
                    vehicleName: trip.vehicleName ?? 'Xe điện',
                  ),
                ),
              ),
              icon: const Icon(Icons.star_rounded, size: 20),
              label: Text(
                'Đánh giá chuyến đi',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB300),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Skip button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context, true),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Đánh giá sau',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.white60,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMetric({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.white38),
        ),
      ],
    );
  }
}
