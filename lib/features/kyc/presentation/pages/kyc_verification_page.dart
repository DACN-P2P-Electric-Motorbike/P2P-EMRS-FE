import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/services/upload_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/kyc_verification.dart';
import '../cubit/kyc_cubit.dart';

class KycVerificationPage extends StatelessWidget {
  const KycVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<KycCubit>()..loadStatus(),
      child: const _KycVerificationView(),
    );
  }
}

class _KycVerificationView extends StatefulWidget {
  const _KycVerificationView();

  @override
  State<_KycVerificationView> createState() => _KycVerificationViewState();
}

class _KycVerificationViewState extends State<_KycVerificationView> {
  final _imagePicker = ImagePicker();
  _PickedKycFile? _selfie;
  _PickedKycFile? _idFront;
  _PickedKycFile? _idBack;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KycCubit, KycState>(
      listener: (context, state) {
        if (state.viewStatus == KycViewStatus.submitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Đã gửi hồ sơ KYC. Vui lòng chờ quản trị viên duyệt.',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final verification = state.verification;
        final canSubmit = verification.canSubmit && !state.isBusy;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'Xác minh danh tính',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            actions: [
              IconButton(
                onPressed: state.isBusy
                    ? null
                    : () => context.read<KycCubit>().loadStatus(),
                icon: const Icon(Icons.refresh),
                tooltip: 'Làm mới',
              ),
            ],
          ),
          body: state.viewStatus == KycViewStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildStatusCard(verification),
                      const SizedBox(height: 20),
                      if (verification.canSubmit) ...[
                        _buildUploadCard(
                          title: 'Ảnh selfie',
                          subtitle:
                              _selfie?.name ?? 'Chụp hoặc chọn ảnh khuôn mặt',
                          icon: Icons.face_retouching_natural_outlined,
                          selected: _selfie != null,
                          onTap: _pickSelfie,
                          trailing: IconButton(
                            onPressed: _pickSelfieFromFile,
                            icon: const Icon(Icons.photo_library_outlined),
                            tooltip: 'Chọn từ thư viện',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildUploadCard(
                          title: 'CCCD mặt trước',
                          subtitle: _idFront?.name ?? 'Chọn ảnh mặt trước',
                          icon: Icons.badge_outlined,
                          selected: _idFront != null,
                          onTap: () => _pickDocument(isFront: true),
                        ),
                        const SizedBox(height: 12),
                        _buildUploadCard(
                          title: 'CCCD mặt sau',
                          subtitle: _idBack?.name ?? 'Chọn ảnh mặt sau',
                          icon: Icons.credit_card_outlined,
                          selected: _idBack != null,
                          onTap: () => _pickDocument(isFront: false),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: canSubmit && !_isUploading
                                ? _submitKyc
                                : null,
                            icon: _isUploading || state.isBusy
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.verified_user_outlined),
                            label: Text(
                              _isUploading ? 'Đang tải ảnh...' : 'Gửi xác minh',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        _buildReadonlyDocuments(verification),
                      ],
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildStatusCard(KycVerification verification) {
    final color = _statusColor(verification.status);
    final icon = _statusIcon(verification.status);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  verification.status.displayName,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _statusDescription(verification.status),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                if (verification.rejectionReason?.isNotEmpty == true) ...[
                  const SizedBox(height: 10),
                  Text(
                    verification.rejectionReason!,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.inputBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                selected ? Icons.check_circle_outline : icon,
                color: selected ? AppColors.primary : AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            trailing ?? const Icon(Icons.upload_file, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildReadonlyDocuments(KycVerification verification) {
    final docs = [
      ('Ảnh selfie', verification.selfieUrl),
      ('CCCD mặt trước', verification.idCardFrontUrl),
      ('CCCD mặt sau', verification.idCardBackUrl),
    ].where((item) => item.$2 != null && item.$2!.isNotEmpty).toList();

    if (docs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hồ sơ đã gửi',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...docs.map(
          (doc) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildUploadCard(
              title: doc.$1,
              subtitle: 'Đã tải lên',
              icon: Icons.image_outlined,
              selected: true,
              onTap: () {},
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickSelfie() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() => _selfie = _PickedKycFile(picked.name, bytes));
    } catch (_) {
      await _pickSelfieFromFile();
    }
  }

  Future<void> _pickSelfieFromFile() async {
    final picked = await _pickImageFile();
    if (picked != null) setState(() => _selfie = picked);
  }

  Future<void> _pickDocument({required bool isFront}) async {
    final picked = await _pickImageFile();
    if (picked == null) return;
    setState(() {
      if (isFront) {
        _idFront = picked;
      } else {
        _idBack = picked;
      }
    });
  }

  Future<_PickedKycFile?> _pickImageFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return null;
    return _PickedKycFile(file.name, bytes);
  }

  Future<void> _submitKyc() async {
    final selfie = _selfie;
    final idFront = _idFront;
    final idBack = _idBack;

    if (selfie == null || idFront == null || idBack == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng thêm đủ ảnh selfie và hai mặt CCCD.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);
    try {
      final uploadService = sl<UploadService>();
      final uploadedSelfie = await uploadService.uploadKycImage(
        fileBytes: selfie.bytes,
        fileName: selfie.name,
      );
      final uploadedFront = await uploadService.uploadKycImage(
        fileBytes: idFront.bytes,
        fileName: idFront.name,
      );
      final uploadedBack = await uploadService.uploadKycImage(
        fileBytes: idBack.bytes,
        fileName: idBack.name,
      );

      if (!mounted) return;
      await context.read<KycCubit>().submit(
        selfieUrl: uploadedSelfie.url,
        idCardFrontUrl: uploadedFront.url,
        idCardBackUrl: uploadedBack.url,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tải ảnh thất bại: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Color _statusColor(KycStatus status) {
    switch (status) {
      case KycStatus.approved:
        return AppColors.success;
      case KycStatus.pending:
        return AppColors.warning;
      case KycStatus.rejected:
        return AppColors.error;
      case KycStatus.notSubmitted:
        return AppColors.primary;
    }
  }

  IconData _statusIcon(KycStatus status) {
    switch (status) {
      case KycStatus.approved:
        return Icons.verified_user;
      case KycStatus.pending:
        return Icons.hourglass_top;
      case KycStatus.rejected:
        return Icons.report_problem_outlined;
      case KycStatus.notSubmitted:
        return Icons.assignment_ind_outlined;
    }
  }

  String _statusDescription(KycStatus status) {
    switch (status) {
      case KycStatus.approved:
        return 'Bạn có thể đăng xe và đặt xe trên DreamRide.';
      case KycStatus.pending:
        return 'Hồ sơ đang được quản trị viên kiểm tra.';
      case KycStatus.rejected:
        return 'Hồ sơ chưa đạt yêu cầu. Vui lòng gửi lại ảnh rõ hơn.';
      case KycStatus.notSubmitted:
        return 'Xác minh KYC là điều kiện để đăng xe hoặc đặt xe.';
    }
  }
}

class _PickedKycFile {
  final String name;
  final Uint8List bytes;

  const _PickedKycFile(this.name, this.bytes);
}
