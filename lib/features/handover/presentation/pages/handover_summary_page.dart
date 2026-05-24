import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/handover.dart';
import '../cubit/handover_cubit.dart';
import '../cubit/handover_state.dart';
import 'check_in_page.dart';
import 'check_out_page.dart';

class HandoverSummaryPage extends StatelessWidget {
  final String bookingId;
  final bool allowCheckOut;

  const HandoverSummaryPage({
    super.key,
    required this.bookingId,
    this.allowCheckOut = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HandoverCubit>()..load(bookingId),
      child: _HandoverSummaryView(
        bookingId: bookingId,
        allowCheckOut: allowCheckOut,
      ),
    );
  }
}

class _HandoverSummaryView extends StatelessWidget {
  final String bookingId;
  final bool allowCheckOut;

  const _HandoverSummaryView({
    required this.bookingId,
    required this.allowCheckOut,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Biên bản bàn giao',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<HandoverCubit>().load(bookingId),
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: BlocConsumer<HandoverCubit, HandoverState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == HandoverViewStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final summary = state.summary;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _HandoverTile(
                title: 'Check-in nhận xe',
                handover: summary?.checkIn,
                emptyLabel: 'Tạo biên bản nhận xe',
                onCreate: () => _openCheckIn(context),
                onConfirm: (id) => _confirm(context, id),
              ),
              const SizedBox(height: 14),
              _HandoverTile(
                title: 'Check-out trả xe',
                handover: summary?.checkOut,
                emptyLabel: 'Tạo biên bản trả xe',
                onCreate: allowCheckOut ? () => _openCheckOut(context) : null,
                onConfirm: (id) => _confirm(context, id),
              ),
              if (summary?.differences.kmDriven != null ||
                  summary?.differences.batteryDelta != null) ...[
                const SizedBox(height: 14),
                _DifferencesPanel(differences: summary!.differences),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _openCheckIn(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CheckInPage(bookingId: bookingId)),
    );
    if (context.mounted) context.read<HandoverCubit>().load(bookingId);
  }

  Future<void> _openCheckOut(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CheckOutPage(bookingId: bookingId)),
    );
    if (context.mounted) context.read<HandoverCubit>().load(bookingId);
  }

  Future<void> _confirm(BuildContext context, String handoverId) async {
    await context.read<HandoverCubit>().confirm(
      handoverId: handoverId,
      bookingId: bookingId,
    );
  }
}

class _HandoverTile extends StatelessWidget {
  final String title;
  final VehicleHandover? handover;
  final String emptyLabel;
  final VoidCallback? onCreate;
  final ValueChanged<String> onConfirm;

  const _HandoverTile({
    required this.title,
    required this.handover,
    required this.emptyLabel,
    required this.onCreate,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final item = handover;
    final complete = item?.isComplete ?? false;
    final color = item == null
        ? AppColors.textMuted
        : complete
        ? AppColors.success
        : AppColors.warning;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                complete ? Icons.verified_outlined : Icons.assignment_outlined,
                color: color,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (item == null) ...[
            Text(
              'Chưa có biên bản.',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: Text(emptyLabel),
            ),
          ] else ...[
            Text(
              complete ? 'Hai bên đã xác nhận.' : 'Chưa đủ xác nhận hai bên.',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              '${item.photos.length} ảnh'
              '${item.batteryLevel != null ? ' · Pin ${item.batteryLevel}%' : ''}'
              '${item.odometerReading != null ? ' · ${item.odometerReading!.toStringAsFixed(1)} km' : ''}',
              style: GoogleFonts.poppins(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
            if (!complete) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => onConfirm(item.id),
                icon: const Icon(Icons.verified_user_outlined),
                label: const Text('Xác nhận'),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _DifferencesPanel extends StatelessWidget {
  final HandoverDifferences differences;

  const _DifferencesPanel({required this.differences});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chênh lệch sau chuyến đi',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          if (differences.kmDriven != null)
            Text('Quãng đường: ${differences.kmDriven!.toStringAsFixed(1)} km'),
          if (differences.batteryDelta != null)
            Text(
              'Pin: ${differences.batteryDelta! > 0 ? '+' : ''}${differences.batteryDelta}%',
            ),
        ],
      ),
    );
  }
}
