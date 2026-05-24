import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/location_service.dart';
import '../../../../core/services/upload_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/handover.dart';
import '../../domain/usecases/handover_usecases.dart';
import '../cubit/handover_cubit.dart';
import '../cubit/handover_state.dart';

enum HandoverFormMode { checkIn, checkOut }

class HandoverFormPage extends StatelessWidget {
  final String bookingId;
  final HandoverFormMode mode;
  final int? initialBatteryLevel;
  final double? latitude;
  final double? longitude;

  const HandoverFormPage({
    super.key,
    required this.bookingId,
    required this.mode,
    this.initialBatteryLevel,
    this.latitude,
    this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HandoverCubit>()..load(bookingId),
      child: _HandoverFormView(
        bookingId: bookingId,
        mode: mode,
        initialBatteryLevel: initialBatteryLevel,
        latitude: latitude,
        longitude: longitude,
      ),
    );
  }
}

class _HandoverFormView extends StatefulWidget {
  final String bookingId;
  final HandoverFormMode mode;
  final int? initialBatteryLevel;
  final double? latitude;
  final double? longitude;

  const _HandoverFormView({
    required this.bookingId,
    required this.mode,
    this.initialBatteryLevel,
    this.latitude,
    this.longitude,
  });

  @override
  State<_HandoverFormView> createState() => _HandoverFormViewState();
}

class _HandoverFormViewState extends State<_HandoverFormView> {
  final _odometerController = TextEditingController();
  final _batteryController = TextEditingController();
  final _notesController = TextEditingController();
  final List<_PickedHandoverPhoto> _photos = [];
  bool _isUploading = false;

  bool get _isCheckIn => widget.mode == HandoverFormMode.checkIn;

  String get _title => _isCheckIn ? 'Check-in nhận xe' : 'Check-out trả xe';

  String get _submitLabel =>
      _isCheckIn ? 'Gửi biên bản nhận xe' : 'Gửi biên bản trả xe';

  @override
  void initState() {
    super.initState();
    if (widget.initialBatteryLevel != null) {
      _batteryController.text = widget.initialBatteryLevel!.toString();
    }
  }

  @override
  void dispose() {
    _odometerController.dispose();
    _batteryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HandoverCubit, HandoverState>(
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
        final existing = _existingHandover(state.summary);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              _title,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            actions: [
              IconButton(
                onPressed: state.isBusy
                    ? null
                    : () =>
                          context.read<HandoverCubit>().load(widget.bookingId),
                icon: const Icon(Icons.refresh),
                tooltip: 'Làm mới',
              ),
            ],
          ),
          body: state.status == HandoverViewStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      if (existing != null)
                        _buildExistingHandover(context, state, existing)
                      else
                        _buildForm(context, state),
                    ],
                  ),
                ),
        );
      },
    );
  }

  VehicleHandover? _existingHandover(HandoverSummary? summary) {
    if (summary == null) return null;
    return _isCheckIn ? summary.checkIn : summary.checkOut;
  }

  Widget _buildExistingHandover(
    BuildContext context,
    HandoverState state,
    VehicleHandover handover,
  ) {
    final complete = handover.isComplete;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatusPanel(
          complete: complete,
          title: complete ? 'Biên bản đã hoàn tất' : 'Đang chờ xác nhận',
          subtitle: complete
              ? 'Hai bên đã xác nhận tình trạng xe.'
              : 'Mỗi bên cần xác nhận biên bản trước khi tiếp tục.',
        ),
        const SizedBox(height: 16),
        _HandoverFacts(handover: handover),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: state.isBusy
                ? null
                : () async {
                    if (complete) {
                      Navigator.pop(context, true);
                      return;
                    }
                    final updated = await context.read<HandoverCubit>().confirm(
                      handoverId: handover.id,
                      bookingId: widget.bookingId,
                    );
                    if (!context.mounted || updated == null) return;
                    if (updated.isComplete || !_isCheckIn) {
                      Navigator.pop(context, true);
                    }
                  },
            icon: state.isBusy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(complete ? Icons.arrow_forward : Icons.verified),
            label: Text(
              complete ? 'Tiếp tục' : 'Xác nhận biên bản',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context, HandoverState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ảnh tình trạng xe',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ..._photos.map(
              (photo) => Chip(
                label: Text(photo.name),
                avatar: const Icon(Icons.image_outlined, size: 18),
                onDeleted: () => setState(() => _photos.remove(photo)),
              ),
            ),
            ActionChip(
              avatar: const Icon(Icons.add_photo_alternate_outlined, size: 18),
              label: const Text('Thêm ảnh'),
              onPressed: state.isBusy || _isUploading ? null : _pickPhoto,
            ),
          ],
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _odometerController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Odometer (km)',
            prefixIcon: Icon(Icons.speed_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _batteryController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Pin (%)',
            prefixIcon: Icon(Icons.battery_charging_full_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Ghi chú tình trạng xe',
            prefixIcon: Icon(Icons.notes_outlined),
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: state.isBusy || _isUploading ? null : _submit,
            icon: state.isBusy || _isUploading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.assignment_turned_in_outlined),
            label: Text(
              _isUploading ? 'Đang tải ảnh...' : _submitLabel,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickPhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;
    setState(() => _photos.add(_PickedHandoverPhoto(file.name, bytes)));
  }

  Future<void> _submit() async {
    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng thêm ít nhất một ảnh bàn giao.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final battery = int.tryParse(_batteryController.text.trim());
    if (_batteryController.text.trim().isNotEmpty &&
        (battery == null || battery < 0 || battery > 100)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pin phải là số từ 0 đến 100.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final cubit = context.read<HandoverCubit>();
    setState(() => _isUploading = true);
    try {
      final uploadService = sl<UploadService>();
      final location = await _resolveLocation();
      final uploaded = <HandoverPhotoInput>[];
      for (final photo in _photos) {
        final result = await uploadService.uploadHandoverImage(
          fileBytes: photo.bytes,
          fileName: photo.name,
        );
        uploaded.add(
          HandoverPhotoInput(
            photoUrl: result.url,
            photoType: _photos.indexOf(photo) == 0 ? 'front' : 'custom',
            latitude: location.$1,
            longitude: location.$2,
            capturedAt: DateTime.now(),
          ),
        );
      }

      if (!mounted) return;
      final params = HandoverMutationParams(
        bookingId: widget.bookingId,
        photos: uploaded,
        odometerReading: double.tryParse(
          _odometerController.text.trim().replaceAll(',', '.'),
        ),
        batteryLevel: battery,
        latitude: location.$1,
        longitude: location.$2,
        notes: _notesController.text.trim(),
      );

      final handover = _isCheckIn
          ? await cubit.createCheckIn(params)
          : await cubit.createCheckOut(params);

      if (!mounted || handover == null) return;
      if (handover.isComplete || !_isCheckIn) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Đã gửi biên bản. Vui lòng chờ bên còn lại xác nhận.',
            ),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không gửi được biên bản: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<(double?, double?)> _resolveLocation() async {
    if (widget.latitude != null && widget.longitude != null) {
      return (widget.latitude, widget.longitude);
    }
    try {
      final result = await sl<LocationService>().getCurrentPositionResult();
      final position = result.position;
      return (position?.latitude, position?.longitude);
    } catch (_) {
      return (null, null);
    }
  }
}

class _StatusPanel extends StatelessWidget {
  final bool complete;
  final String title;
  final String subtitle;

  const _StatusPanel({
    required this.complete,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final color = complete ? AppColors.success : AppColors.warning;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            complete ? Icons.verified_outlined : Icons.hourglass_top_outlined,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HandoverFacts extends StatelessWidget {
  final VehicleHandover handover;

  const _HandoverFacts({required this.handover});

  @override
  Widget build(BuildContext context) {
    final facts = [
      if (handover.odometerReading != null)
        ('Odometer', '${handover.odometerReading!.toStringAsFixed(1)} km'),
      if (handover.batteryLevel != null) ('Pin', '${handover.batteryLevel}%'),
      ('Ảnh', '${handover.photos.length} ảnh'),
      ('Chủ xe', handover.confirmedByOwner ? 'Đã xác nhận' : 'Chưa xác nhận'),
      (
        'Người thuê',
        handover.confirmedByRenter ? 'Đã xác nhận' : 'Chưa xác nhận',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: facts
            .map(
              (fact) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        fact.$1,
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      fact.$2,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _PickedHandoverPhoto {
  final String name;
  final Uint8List bytes;

  const _PickedHandoverPhoto(this.name, this.bytes);
}
