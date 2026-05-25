import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../injection_container.dart';
import '../../../booking/domain/entities/booking_policy.dart';
import '../../../booking/domain/repositories/booking_repository.dart';
import '../../../booking/presentation/bloc/booking_bloc.dart';
import '../../../booking/presentation/bloc/booking_event.dart';
import '../../../booking/presentation/bloc/booking_state.dart';
import '../../domain/entities/availability_summary.dart';
import '../../domain/entities/vehicle_entity.dart';

/// Enhanced Booking Bottom Sheet with full BLoC integration
class BookingBottomSheet extends StatelessWidget {
  final VehicleEntity vehicle;
  final VehicleAvailabilitySummary? availabilitySummary;

  const BookingBottomSheet({
    super.key,
    required this.vehicle,
    this.availabilitySummary,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BookingBloc>(),
      child: _EnhancedBookingContent(
        vehicle: vehicle,
        availabilitySummary: availabilitySummary,
      ),
    );
  }
}

class _ProtectionPlanOption {
  final String value;
  final String label;
  final String description;
  final double feeRate;
  final double deductible;
  final double coverageLimit;
  final IconData icon;

  const _ProtectionPlanOption({
    required this.value,
    required this.label,
    required this.description,
    required this.feeRate,
    required this.deductible,
    required this.coverageLimit,
    required this.icon,
  });
}

class _EnhancedBookingContent extends StatefulWidget {
  final VehicleEntity vehicle;
  final VehicleAvailabilitySummary? availabilitySummary;

  const _EnhancedBookingContent({
    required this.vehicle,
    required this.availabilitySummary,
  });

  @override
  State<_EnhancedBookingContent> createState() =>
      _EnhancedBookingContentState();
}

class _EnhancedBookingContentState extends State<_EnhancedBookingContent> {
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _rentalType = 'hourly'; // hourly or daily
  final _notesController = TextEditingController();
  bool _isProcessing = false;
  String _selectedProtectionPlan = 'STANDARD';
  bool _prepaidCharging = false;
  bool _roadsideSupport = false;
  BookingPolicy _bookingPolicy = BookingPolicy.fallback;
  String? _activeLockId;
  DateTime? _lockExpiresAt;
  Duration _remainingLockTime = Duration.zero;
  Timer? _lockTimer;
  late final BookingBloc _bookingBloc;
  late final BookingRepository _bookingRepository;
  static const _minRentalDuration = Duration(minutes: 30);
  static const _maxRentalDuration = Duration(days: 30);
  static const _fallbackProtectionPlans = [
    _ProtectionPlanOption(
      value: 'BASIC',
      label: 'Cơ bản',
      description: 'Không phụ phí, tự chịu khấu trừ cao hơn',
      feeRate: 0,
      deductible: 3000000,
      coverageLimit: 5000000,
      icon: Icons.shield_outlined,
    ),
    _ProtectionPlanOption(
      value: 'STANDARD',
      label: 'Tiêu chuẩn',
      description: 'Cân bằng phí và mức khấu trừ',
      feeRate: 0.05,
      deductible: 1500000,
      coverageLimit: 15000000,
      icon: Icons.verified_user_outlined,
    ),
    _ProtectionPlanOption(
      value: 'PREMIUM',
      label: 'Cao cấp',
      description: 'Phí cao hơn, khấu trừ thấp hơn',
      feeRate: 0.1,
      deductible: 500000,
      coverageLimit: 30000000,
      icon: Icons.workspace_premium_outlined,
    ),
  ];

  // Normalize DateTime to midnight (00:00:00)
  DateTime _normalizeToMidnight(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  void initState() {
    super.initState();
    _bookingBloc = context.read<BookingBloc>();
    _bookingRepository = sl<BookingRepository>();
    unawaited(_loadBookingPolicy());
  }

  @override
  void dispose() {
    _lockTimer?.cancel();
    final lockId = _activeLockId;
    if (lockId != null) {
      unawaited(_bookingRepository.releaseBookingLock(lockId));
    }
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadBookingPolicy() async {
    final result = await _bookingRepository.getBookingPolicy();
    if (!mounted) return;

    result.fold((_) {}, (policy) {
      final options = _protectionOptionsForPolicy(policy);
      final selectedPlanStillAvailable = options.any(
        (plan) => plan.value == _selectedProtectionPlan,
      );
      final policyDefaultPlan = options
          .firstWhere(
            (plan) => plan.value == policy.defaultProtectionPlan,
            orElse: () => options.first,
          )
          .value;
      final canUsePrepaidCharging = _canUsePrepaidChargingForPolicy(policy);

      setState(() {
        _bookingPolicy = policy;
        if (!selectedPlanStillAvailable) {
          _selectedProtectionPlan = policyDefaultPlan;
        }
        if (!canUsePrepaidCharging) {
          _prepaidCharging = false;
        }
      });
    });
  }

  List<_ProtectionPlanOption> _protectionOptionsForPolicy(
    BookingPolicy policy,
  ) {
    final options = policy.protectionPlans
        .map(_protectionOptionFromPolicy)
        .toList(growable: false);
    return options.isEmpty ? _fallbackProtectionPlans : options;
  }

  _ProtectionPlanOption _protectionOptionFromPolicy(
    ProtectionPlanPolicy policy,
  ) {
    final value = policy.protectionPlan.toUpperCase();
    final fallback = _fallbackProtectionPlans.firstWhere(
      (plan) => plan.value == value,
      orElse: () => _fallbackProtectionPlans[1],
    );

    return _ProtectionPlanOption(
      value: value,
      label: fallback.value == value ? fallback.label : value,
      description: fallback.description,
      feeRate: policy.feeRate,
      deductible: policy.deductible,
      coverageLimit: policy.coverageLimit,
      icon: fallback.icon,
    );
  }

  bool _canUsePrepaidChargingForPolicy(BookingPolicy policy) {
    return !policy.prepaidCharging.requiresBatteryReturnMinimum ||
        widget.vehicle.batteryReturnMin != null;
  }

  // Calculate total hours
  int get _totalHours {
    if (_startDate == null || _endDate == null) return 0;

    if (_rentalType == 'hourly') {
      if (_startTime == null || _endTime == null) return 0;

      DateTime start = DateTime(
        _startDate!.year,
        _startDate!.month,
        _startDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );
      DateTime end = DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      final difference = end.difference(start);
      return difference.inHours + (difference.inMinutes % 60 > 0 ? 1 : 0);
    } else {
      // Daily rental
      final days = _endDate!.difference(_startDate!).inDays + 1;
      return days * 24;
    }
  }

  // Calculate total price
  double get _totalPrice {
    if (_totalHours <= 0) return 0;

    if (_rentalType == 'daily') {
      final days = _endDate!.difference(_startDate!).inDays + 1;
      return (widget.vehicle.pricePerDay ?? widget.vehicle.pricePerHour * 24) *
          days;
    } else {
      return widget.vehicle.pricePerHour * _totalHours;
    }
  }

  _ProtectionPlanOption get _selectedProtection {
    final plans = _protectionPlans;
    return plans.firstWhere(
      (plan) => plan.value == _selectedProtectionPlan,
      orElse: () => plans.firstWhere(
        (plan) => plan.value == _bookingPolicy.defaultProtectionPlan,
        orElse: () => plans.first,
      ),
    );
  }

  List<_ProtectionPlanOption> get _protectionPlans =>
      _protectionOptionsForPolicy(_bookingPolicy);

  double get _protectionFee =>
      (_totalPrice * _selectedProtection.feeRate).round().toDouble();

  double get _prepaidChargingFee => _bookingPolicy.prepaidCharging.fee;

  int get _prepaidChargingCreditPercent =>
      _bookingPolicy.prepaidCharging.creditPercent;

  double get _selectedPrepaidChargingFee =>
      _prepaidCharging ? _prepaidChargingFee : 0;

  double get _roadsideSupportFee => _bookingPolicy.roadsideSupport.fee;

  double get _roadsideSupportCreditAmount =>
      _bookingPolicy.roadsideSupport.creditAmount;

  double get _selectedRoadsideSupportFee =>
      _roadsideSupport ? _roadsideSupportFee : 0;

  bool get _canUsePrepaidCharging =>
      _canUsePrepaidChargingForPolicy(_bookingPolicy);

  double get _checkoutTotal =>
      _totalPrice +
      _protectionFee +
      _selectedPrepaidChargingFee +
      _selectedRoadsideSupportFee +
      (widget.vehicle.deposit ?? 0);

  AvailabilityRangeEvaluation? get _availabilityEvaluation {
    final summary = widget.availabilitySummary;
    final start = _startDateTime;
    final end = _endDateTime;
    if (summary == null ||
        summary.rules.isEmpty ||
        start == null ||
        end == null ||
        !end.isAfter(start)) {
      return null;
    }
    return summary.evaluateRange(start, end);
  }

  // Get start DateTime
  DateTime? get _startDateTime {
    if (_startDate == null) return null;
    if (_rentalType == 'hourly' && _startTime == null) return null;

    return DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _startTime?.hour ?? 0,
      _startTime?.minute ?? 0,
    );
  }

  // Get end DateTime
  DateTime? get _endDateTime {
    if (_endDate == null) return null;
    if (_rentalType == 'hourly' && _endTime == null) return null;

    return DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      _endTime?.hour ?? 23,
      _endTime?.minute ?? 59,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingCreated) {
          _lockTimer?.cancel();
          _activeLockId = null;
          // Save booking ID and router/navigator before closing
          final bookingId = state.booking.id;
          final router = GoRouter.of(context);
          final navigator = Navigator.of(context);
          final scaffoldMessenger = ScaffoldMessenger.of(context);

          // Close bottom sheet
          navigator.pop();
          final controller = scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Đặt xe thành công!',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          widget.vehicle.instantBook
                              ? 'Xe đã được xác nhận tự động'
                              : 'Chờ chủ xe xác nhận',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Xem',
                textColor: Colors.white,
                onPressed: () {
                  scaffoldMessenger.hideCurrentSnackBar();
                },
              ),
            ),
          );

          controller.closed.then((_) {
            router.go('/bookings/$bookingId');
          });
        } else if (state is BookingLockCreated) {
          setState(() {
            _isProcessing = false;
            _activeLockId = state.lock.id;
            _lockExpiresAt = state.lock.expiresAt;
          });
          _startLockTimer();
        } else if (state is BookingFailure) {
          // Show error message
          setState(() => _isProcessing = false);
          final needsKyc = state.message.toLowerCase().contains('kyc');
          final router = GoRouter.of(context);
          final navigator = Navigator.of(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              action: needsKyc
                  ? SnackBarAction(
                      label: 'Xác minh',
                      textColor: Colors.white,
                      onPressed: () {
                        navigator.pop();
                        router.push('/kyc');
                      },
                    )
                  : null,
            ),
          );
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Header
                _buildHeader(context),

                // Content
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Vehicle summary
                      _buildVehicleSummary(),

                      const SizedBox(height: 24),

                      // Rental type selector
                      _buildRentalTypeSelector(),

                      const SizedBox(height: 24),

                      // Date & Time selection
                      _buildDateTimeSelection(),

                      const SizedBox(height: 24),

                      if (_availabilityEvaluation != null) ...[
                        _buildAvailabilityPreview(_availabilityEvaluation!),
                        const SizedBox(height: 24),
                      ],

                      // Notes (optional)
                      _buildNotesField(),

                      const SizedBox(height: 24),

                      if (_totalPrice > 0) ...[
                        _buildProtectionPlanSelector(),
                        const SizedBox(height: 24),
                        if (_canUsePrepaidCharging) ...[
                          _buildPrepaidChargingAddon(),
                          const SizedBox(height: 24),
                        ],
                        _buildRoadsideSupportAddon(),
                        const SizedBox(height: 24),
                      ],

                      // Price breakdown
                      if (_totalPrice > 0) _buildPriceBreakdown(),

                      const SizedBox(height: 24),

                      if (_activeLockId != null) ...[
                        _buildLockCountdownCard(),
                        const SizedBox(height: 24),
                      ],

                      // Important notes
                      _buildImportantNotes(),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Book button
                _buildBookButton(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.electric_moped,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đặt xe',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Chọn thời gian và xác nhận',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _releaseActiveLock();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
            tooltip: 'Đóng',
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Vehicle image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: widget.vehicle.images.isNotEmpty
                ? AppNetworkImage(
                    imageUrl: widget.vehicle.images.first,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    cacheWidth: 180,
                    errorWidget: _buildImagePlaceholder(),
                  )
                : _buildImagePlaceholder(),
          ),
          const SizedBox(width: 16),
          // Vehicle info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.vehicle.brand.displayName,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.vehicle.displayName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.vehicle.licensePlate,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.battery_charging_full,
                      size: 16,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.vehicle.batteryLevel}%',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.vehicle.address,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.electric_moped,
        size: 40,
        color: AppColors.textMuted,
      ),
    );
  }

  Widget _buildRentalTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Loại thuê',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildRentalTypeChip(
                label: 'Theo giờ',
                value: 'hourly',
                price: widget.vehicle.formattedPricePerHour,
                icon: Icons.access_time,
              ),
            ),
            const SizedBox(width: 12),
            if (widget.vehicle.pricePerDay != null)
              Expanded(
                child: _buildRentalTypeChip(
                  label: 'Theo ngày',
                  value: 'daily',
                  price: widget.vehicle.formattedPricePerDay,
                  icon: Icons.calendar_today,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildRentalTypeChip({
    required String label,
    required String value,
    required String price,
    required IconData icon,
  }) {
    final isSelected = _rentalType == value;
    return InkWell(
      onTap: () => setState(() {
        _releaseActiveLock();
        _rentalType = value;
        // Reset times when switching
        if (value == 'daily') {
          _startTime = null;
          _endTime = null;
        }
      }),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isSelected
                    ? Colors.white.withOpacity(0.9)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thời gian thuê',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // Start date & time
        _buildDateTimePicker(
          label: 'Bắt đầu',
          date: _startDate,
          time: _startTime,
          onDateTap: () async {
            final today = _normalizeToMidnight(DateTime.now());
            final date = await showDatePicker(
              context: context,
              initialDate: _startDate ?? today,
              firstDate: today,
              lastDate: today.add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.primary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              setState(() {
                _releaseActiveLock();
                _startDate = date;
              });
            }
          },
          onTimeTap: _rentalType == 'hourly'
              ? () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _startTime ?? TimeOfDay.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppColors.primary,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (time != null) {
                    setState(() {
                      _releaseActiveLock();
                      _startTime = time;
                    });
                  }
                }
              : null,
        ),

        const SizedBox(height: 12),

        // End date & time
        _buildDateTimePicker(
          label: 'Kết thúc',
          date: _endDate,
          time: _endTime,
          onDateTap: () async {
            final today = _normalizeToMidnight(DateTime.now());
            final minDate = _startDate ?? today;
            final date = await showDatePicker(
              context: context,
              initialDate: _endDate ?? minDate,
              firstDate: minDate,
              lastDate: today.add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.primary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              setState(() {
                _releaseActiveLock();
                _endDate = date;
              });
            }
          },
          onTimeTap: _rentalType == 'hourly'
              ? () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _endTime ?? TimeOfDay.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppColors.primary,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (time != null) {
                    setState(() {
                      _releaseActiveLock();
                      _endTime = time;
                    });
                  }
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required DateTime? date,
    required TimeOfDay? time,
    required VoidCallback onDateTap,
    VoidCallback? onTimeTap,
  }) {
    return Row(
      children: [
        Expanded(
          flex: onTimeTap != null ? 2 : 1,
          child: InkWell(
            onTap: onDateTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: date != null ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: date != null
                        ? AppColors.primary
                        : AppColors.textMuted,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          date != null
                              ? DateFormat('dd/MM/yyyy').format(date)
                              : 'Chọn ngày',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: date != null
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (onTimeTap != null) ...[
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: onTimeTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: time != null ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 20,
                      color: time != null
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Giờ',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Text(
                            time != null ? time.format(context) : '--:--',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: time != null
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAvailabilityPreview(AvailabilityRangeEvaluation evaluation) {
    final canBook = evaluation.canBook;
    final color = canBook ? AppColors.success : AppColors.error;
    final icon = canBook
        ? Icons.event_available_outlined
        : Icons.event_busy_outlined;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lịch khả dụng',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  evaluation.message,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Ghi chú',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(tùy chọn)',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 3,
          maxLength: 200,
          decoration: InputDecoration(
            hintText: 'Thêm ghi chú cho chủ xe (nếu có)...',
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProtectionPlanSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gói bảo vệ',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ..._protectionPlans.map(_buildProtectionPlanTile),
      ],
    );
  }

  Widget _buildProtectionPlanTile(_ProtectionPlanOption plan) {
    final isSelected = _selectedProtectionPlan == plan.value;
    final fee = (_totalPrice * plan.feeRate).roundToDouble();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => setState(() => _selectedProtectionPlan = plan.value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                plan.icon,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            plan.label,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          plan.feeRate == 0
                              ? 'Miễn phí'
                              : '+${_formatPrice(fee)}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.description,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Khấu trừ ${_formatPrice(plan.deductible)} • Hạn mức ${_formatPrice(plan.coverageLimit)}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrepaidChargingAddon() {
    return Container(
      decoration: BoxDecoration(
        color: _prepaidCharging
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _prepaidCharging ? AppColors.primary : AppColors.border,
          width: _prepaidCharging ? 2 : 1,
        ),
      ),
      child: SwitchListTile(
        value: _prepaidCharging,
        onChanged: (value) => setState(() => _prepaidCharging = value),
        activeThumbColor: AppColors.primary,
        secondary: Icon(
          Icons.battery_charging_full_outlined,
          color: _prepaidCharging ? AppColors.primary : AppColors.textMuted,
        ),
        title: Text(
          'Sạc trả trước',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '+${_formatPrice(_prepaidChargingFee)} - bao gồm $_prepaidChargingCreditPercent% thiếu hụt pin khi trả xe',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildRoadsideSupportAddon() {
    return Container(
      decoration: BoxDecoration(
        color: _roadsideSupport
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _roadsideSupport ? AppColors.primary : AppColors.border,
          width: _roadsideSupport ? 2 : 1,
        ),
      ),
      child: SwitchListTile(
        value: _roadsideSupport,
        onChanged: (value) => setState(() => _roadsideSupport = value),
        activeThumbColor: AppColors.primary,
        secondary: Icon(
          Icons.support_agent_outlined,
          color: _roadsideSupport ? AppColors.primary : AppColors.textMuted,
        ),
        title: Text(
          'Hỗ trợ cứu hộ',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '+${_formatPrice(_roadsideSupportFee)} - bao gồm ${_formatPrice(_roadsideSupportCreditAmount)} phí cứu hộ sau chuyến',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          // Duration
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thời gian',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '$_totalHours giờ',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Giá thuê',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _formatPrice(_totalPrice),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gói bảo vệ ${_selectedProtection.label}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _formatPrice(_protectionFee),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (_prepaidCharging) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sạc trả trước ($_prepaidChargingCreditPercent% pin)',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  _formatPrice(_selectedPrepaidChargingFee),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
          if (_roadsideSupport) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hỗ trợ cứu hộ',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  _formatPrice(_selectedRoadsideSupportFee),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
          if (widget.vehicle.deposit != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Tiền cọc',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Tooltip(
                      message: 'Sẽ được hoàn lại sau khi trả xe',
                      child: Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                Text(
                  _formatPrice(widget.vehicle.deposit!),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 24),
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng thanh toán',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                _formatPrice(_checkoutTotal),
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImportantNotes() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: AppColors.info),
              const SizedBox(width: 8),
              Text(
                'Lưu ý quan trọng',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildNote(
            _activeLockId == null
                ? 'Giữ chỗ trước khi xác nhận để tránh trùng lịch'
                : 'Chỗ đang được giữ tạm thời trong lúc bạn xác nhận',
          ),
          _buildNote(
            widget.vehicle.instantBook
                ? 'Xe đặt nhanh sẽ tự động xác nhận sau khi gửi yêu cầu'
                : 'Booking sẽ ở trạng thái "Chờ xác nhận"',
          ),
          if (!widget.vehicle.instantBook)
            _buildNote('Chủ xe có thể chấp nhận hoặc từ chối yêu cầu'),
          _buildNote('Bạn sẽ nhận thông báo khi có phản hồi'),
          _buildNote(
            'Gói bảo vệ là mô phỏng nội bộ, không phải bảo hiểm bên thứ ba',
          ),
          if (_prepaidCharging)
            _buildNote(
              'Sạc trả trước bao gồm $_prepaidChargingCreditPercent% thiếu hụt pin; phần vượt mức vẫn được tính sau chuyến',
            ),
          if (_roadsideSupport)
            _buildNote(
              'Hỗ trợ cứu hộ bao gồm ${_formatPrice(_roadsideSupportCreditAmount)} phí cứu hộ; phần vượt mức vẫn được tính sau chuyến',
            ),
          if (widget.vehicle.deposit != null)
            _buildNote('Tiền cọc sẽ được hoàn lại sau khi trả xe'),
        ],
      ),
    );
  }

  Widget _buildNote(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.info,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton(BuildContext context) {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        final isLoading = state is BookingLoading || _isProcessing;
        final validationMessage = _bookingValidationMessage;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.border)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canBook && !isLoading ? _handleBooking : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: AppColors.textMuted,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _activeLockId == null
                                ? Icons.lock_clock
                                : Icons.check_circle_outline,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              validationMessage ?? _bookingButtonLabel,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool get _canBook {
    if (_startDate == null || _endDate == null) return false;
    if (_rentalType == 'hourly' && (_startTime == null || _endTime == null)) {
      return false;
    }
    if (_startDateTime == null || _endDateTime == null) return false;
    return _bookingValidationMessage == null;
  }

  String? get _bookingValidationMessage {
    final start = _startDateTime;
    final end = _endDateTime;
    if (start == null || end == null) {
      return null;
    }
    if (!end.isAfter(start)) {
      return 'Thời gian kết thúc phải sau thời gian bắt đầu';
    }

    // For hourly rentals, the start time must be in the future
    // For daily rentals, the start date must be today or later
    if (_rentalType == 'hourly' && start.isBefore(DateTime.now())) {
      return 'Thời gian bắt đầu phải ở tương lai';
    } else if (_rentalType == 'daily') {
      final todayMidnight = _normalizeToMidnight(DateTime.now());
      if (start.isBefore(todayMidnight)) {
        return 'Ngày bắt đầu phải từ hôm nay trở đi';
      }
    }

    final duration = end.difference(start);
    if (duration < _minRentalDuration) {
      return 'Thời gian thuê tối thiểu là 30 phút';
    }
    if (duration > _maxRentalDuration) {
      return 'Thời gian thuê tối đa là 30 ngày';
    }
    final availabilityEvaluation = _availabilityEvaluation;
    if (availabilityEvaluation != null && !availabilityEvaluation.canBook) {
      return availabilityEvaluation.message;
    }
    return null;
  }

  void _handleBooking() {
    if (!_canBook || _isProcessing) return;

    setState(() => _isProcessing = true);

    if (_activeLockId == null) {
      _bookingBloc.add(
        CreateBookingLockEvent(
          vehicleId: widget.vehicle.id,
          startTime: _startDateTime!,
          endTime: _endDateTime!,
        ),
      );
      return;
    }

    _bookingBloc.add(
      CreateBookingEvent(
        vehicleId: widget.vehicle.id,
        startTime: _startDateTime!,
        endTime: _endDateTime!,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        protectionPlan: _selectedProtectionPlan,
        prepaidCharging: _prepaidCharging,
        roadsideSupport: _roadsideSupport,
      ),
    );
  }

  String get _bookingButtonLabel {
    if (_totalPrice <= 0) return 'Chọn thời gian thuê';
    final price = _formatPrice(_checkoutTotal);
    if (_activeLockId == null) return 'Giữ chỗ 15 phút - $price';
    return 'Xác nhận đặt xe - $price';
  }

  Widget _buildLockCountdownCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_clock, color: AppColors.warning, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đang giữ chỗ',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Hoàn tất xác nhận trước khi hết thời gian',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatDuration(_remainingLockTime),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  void _startLockTimer() {
    _lockTimer?.cancel();
    _tickLockTimer();
    _lockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tickLockTimer(),
    );
  }

  void _tickLockTimer() {
    final expiresAt = _lockExpiresAt;
    if (expiresAt == null) return;

    final remaining = expiresAt.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      _lockTimer?.cancel();
      if (!mounted) return;
      setState(() {
        _activeLockId = null;
        _lockExpiresAt = null;
        _remainingLockTime = Duration.zero;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thời gian giữ chỗ đã hết, vui lòng giữ chỗ lại.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (mounted) {
      setState(() => _remainingLockTime = remaining);
    }
  }

  void _releaseActiveLock() {
    final lockId = _activeLockId;
    if (lockId == null) return;

    _lockTimer?.cancel();
    _activeLockId = null;
    _lockExpiresAt = null;
    _remainingLockTime = Duration.zero;
    unawaited(_bookingRepository.releaseBookingLock(lockId));
  }

  String _formatDuration(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}đ';
  }
}
