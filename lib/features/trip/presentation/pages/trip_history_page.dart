import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/trip_entity.dart';
import '../bloc/trip_bloc.dart';
import '../bloc/trip_event.dart';
import '../bloc/trip_state.dart';

class TripHistoryPage extends StatelessWidget {
  const TripHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<TripBloc>()..add(const LoadTripHistoryEvent()),
      child: const _TripHistoryView(),
    );
  }
}

class _TripHistoryView extends StatelessWidget {
  const _TripHistoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Lịch sử chuyến đi',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<TripBloc, TripState>(
        builder: (context, state) {
          if (state is TripLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TripHistoryLoaded) {
            if (state.trips.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.trips.length,
              itemBuilder: (context, index) =>
                  _TripCard(trip: state.trips[index]),
            );
          }
          if (state is TripFailure) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.route_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Chưa có chuyến đi nào',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Các chuyến đi đã hoàn thành sẽ hiển thị ở đây',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final TripEntity trip;

  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.electric_scooter, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.completedAt != null
                          ? DateFormat('dd/MM/yyyy').format(trip.completedAt!)
                          : 'N/A',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (trip.startedAt != null)
                      Text(
                        '${DateFormat('HH:mm').format(trip.startedAt!)} - ${trip.completedAt != null ? DateFormat('HH:mm').format(trip.completedAt!) : '--'}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              if (trip.hasIssues)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Có sự cố',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStat(Icons.route, trip.formattedDistance, 'Quãng đường'),
              const SizedBox(width: 24),
              _buildStat(Icons.timer, trip.formattedDuration, 'Thời gian'),
              if (trip.startBattery != null && trip.endBattery != null) ...[
                const SizedBox(width: 24),
                _buildStat(
                  Icons.battery_charging_full,
                  '${trip.startBattery!.toStringAsFixed(0)}% → ${trip.endBattery!.toStringAsFixed(0)}%',
                  'Pin',
                ),
              ],
            ],
          ),
          if (trip.startAddress != null || trip.endAddress != null) ...[
            const Divider(height: 24),
            if (trip.startAddress != null)
              _buildAddressRow(Icons.my_location, trip.startAddress!),
            if (trip.endAddress != null) ...[
              const SizedBox(height: 4),
              _buildAddressRow(Icons.location_on, trip.endAddress!),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressRow(IconData icon, String address) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            address,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
