import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../../review/presentation/pages/create_review_page.dart';
import '../../domain/entities/trip_entity.dart';
import '../bloc/trip_bloc.dart';
import '../bloc/trip_event.dart';
import '../bloc/trip_state.dart';

class TripHistoryPage extends StatelessWidget {
  const TripHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TripBloc>()..add(const LoadTripHistoryEvent()),
      child: const _TripHistoryView(),
    );
  }
}

enum _TripFilter { all, normal, issues }

class _TripHistoryView extends StatefulWidget {
  const _TripHistoryView();

  @override
  State<_TripHistoryView> createState() => _TripHistoryViewState();
}

class _TripHistoryViewState extends State<_TripHistoryView> {
  _TripFilter _filter = _TripFilter.all;
  int _visibleCount = 10;

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
            final all = state.trips;
            final normal = all.where((t) => !t.hasIssues).toList();
            final issues = all.where((t) => t.hasIssues).toList();

            final filtered = switch (_filter) {
              _TripFilter.all => all,
              _TripFilter.normal => normal,
              _TripFilter.issues => issues,
            };

            return Column(
              children: [
                // Filter chips
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Tất cả',
                        count: all.length,
                        selected: _filter == _TripFilter.all,
                        onTap: () => setState(() {
                          _filter = _TripFilter.all;
                          _visibleCount = 10;
                        }),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Bình thường',
                        count: normal.length,
                        selected: _filter == _TripFilter.normal,
                        onTap: () => setState(() {
                          _filter = _TripFilter.normal;
                          _visibleCount = 10;
                        }),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Có sự cố',
                        count: issues.length,
                        selected: _filter == _TripFilter.issues,
                        activeColor: AppColors.warning,
                        onTap: () => setState(() {
                          _filter = _TripFilter.issues;
                          _visibleCount = 10;
                        }),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? _buildEmptyState(_filter)
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length > _visibleCount
                              ? _visibleCount + 1
                              : filtered.length,
                          itemBuilder: (context, index) {
                            if (index == _visibleCount) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: TextButton(
                                  onPressed: () =>
                                      setState(() => _visibleCount += 10),
                                  child: Text(
                                    'Xem thêm (${filtered.length - _visibleCount} chuyến đi)',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return _TripCard(trip: filtered[index]);
                          },
                        ),
                ),
              ],
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

  Widget _buildEmptyState(_TripFilter filter) {
    final String message;
    final IconData icon;
    if (filter == _TripFilter.issues) {
      icon = Icons.check_circle_outline;
      message = 'Không có chuyến đi nào có sự cố';
    } else if (filter == _TripFilter.normal) {
      icon = Icons.route_outlined;
      message = 'Không có chuyến đi bình thường';
    } else {
      icon = Icons.route_outlined;
      message = 'Các chuyến đi đã hoàn thành sẽ hiển thị ở đây';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[300]),
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
            message,
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

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  final Color? activeColor;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? color : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: selected ? color : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
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
          const Divider(height: 20),
          // Review button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateReviewPage(
                    vehicleId: trip.vehicleId,
                    vehicleName: trip.vehicleName ?? 'Xe đã thuê',
                    bookingId: trip.bookingId,
                  ),
                ),
              ),
              icon: const Icon(Icons.star_outline_rounded, size: 16),
              label: Text(
                'Đánh giá chuyến đi',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warning,
                side: const BorderSide(color: AppColors.warning),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
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
          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
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
