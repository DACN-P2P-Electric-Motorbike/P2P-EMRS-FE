import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/financial_summary.dart';
import '../cubit/financial_cubit.dart';
import '../cubit/financial_state.dart';

class FinancialSummaryCard extends StatelessWidget {
  final bool allowDisputes;
  final ValueChanged<PostTripChargeEntity>? onDisputeCharge;

  const FinancialSummaryCard({
    super.key,
    this.allowDisputes = false,
    this.onDisputeCharge,
  });

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinancialCubit, FinancialState>(
      builder: (context, state) {
        switch (state.status) {
          case FinancialViewStatus.initial:
          case FinancialViewStatus.loading:
            return _CardShell(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(minHeight: 3),
                ],
              ),
            );
          case FinancialViewStatus.failure:
            return _CardShell(
              child: Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppColors.warning,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Không tải được thông tin cọc',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          case FinancialViewStatus.loaded:
            final summary = state.summary;
            if (summary == null || !summary.hasFinancialActivity) {
              return const SizedBox.shrink();
            }
            return _buildSummary(summary);
        }
      },
    );
  }

  Widget _buildSummary(FinancialSummaryEntity summary) {
    final deposit = summary.deposit;
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(deposit: deposit),
          const SizedBox(height: 16),
          if (deposit != null) ...[
            _buildMoneyRow(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Tiền cọc đã giữ',
              value: deposit.heldAmount,
            ),
            const SizedBox(height: 12),
          ],
          _buildMoneyRow(
            icon: Icons.pending_actions_outlined,
            label: 'Phí chờ xử lý',
            value: summary.totalPendingCharges,
            valueColor: summary.totalPendingCharges > 0
                ? AppColors.warning
                : AppColors.textPrimary,
          ),
          const SizedBox(height: 12),
          _buildMoneyRow(
            icon: Icons.fact_check_outlined,
            label: 'Phí đã duyệt',
            value: summary.totalApprovedCharges,
            valueColor: summary.totalApprovedCharges > 0
                ? AppColors.warning
                : AppColors.textPrimary,
          ),
          const SizedBox(height: 12),
          _buildMoneyRow(
            icon: Icons.remove_circle_outline,
            label: 'Đã khấu trừ',
            value: summary.totalCapturedCharges,
            valueColor: summary.totalCapturedCharges > 0
                ? AppColors.error
                : AppColors.textPrimary,
          ),
          const Divider(height: 28),
          _buildMoneyRow(
            icon: Icons.replay_circle_filled_outlined,
            label: 'Dự kiến hoàn',
            value: summary.releasableDeposit,
            valueColor: AppColors.success,
            emphasize: true,
          ),
          if (summary.charges.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              'Phí sau chuyến',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            ...summary.charges.map(_buildChargeRow),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader({DepositLedgerEntity? deposit}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.account_balance_wallet_outlined,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cọc & phí sau chuyến',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (deposit != null) ...[
                const SizedBox(height: 6),
                _StatusPill(
                  text: deposit.status.displayText,
                  color: _depositStatusColor(deposit.status),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoneyRow({
    required IconData icon,
    required String label,
    required double value,
    Color valueColor = AppColors.textPrimary,
    bool emphasize = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            _currency.format(value),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: emphasize ? 16 : 14,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChargeRow(PostTripChargeEntity charge) {
    final color = _chargeStatusColor(charge.status);
    final canDispute =
        allowDisputes &&
        onDisputeCharge != null &&
        (charge.status == PostTripChargeStatus.pendingReview ||
            charge.status == PostTripChargeStatus.approved);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  charge.type.displayText,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _StatusPill(text: charge.status.displayText, color: color),
            ],
          ),
          if (charge.description.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              charge.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              _currency.format(charge.amount),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (canDispute) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => onDisputeCharge?.call(charge),
                icon: const Icon(Icons.report_problem_outlined, size: 16),
                label: Text(
                  'Khiếu nại phí',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _depositStatusColor(DepositLedgerStatus status) {
    switch (status) {
      case DepositLedgerStatus.held:
      case DepositLedgerStatus.releasePending:
        return AppColors.info;
      case DepositLedgerStatus.pendingCharges:
      case DepositLedgerStatus.disputed:
      case DepositLedgerStatus.partiallyCaptured:
        return AppColors.warning;
      case DepositLedgerStatus.captured:
        return AppColors.error;
      case DepositLedgerStatus.released:
      case DepositLedgerStatus.refunded:
        return AppColors.success;
      case DepositLedgerStatus.notHeld:
        return AppColors.textMuted;
    }
  }

  Color _chargeStatusColor(PostTripChargeStatus status) {
    switch (status) {
      case PostTripChargeStatus.pendingReview:
      case PostTripChargeStatus.approved:
      case PostTripChargeStatus.disputed:
        return AppColors.warning;
      case PostTripChargeStatus.deductedFromDeposit:
        return AppColors.error;
      case PostTripChargeStatus.waived:
      case PostTripChargeStatus.paid:
        return AppColors.success;
      case PostTripChargeStatus.cancelled:
        return AppColors.textMuted;
    }
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;

  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusPill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
