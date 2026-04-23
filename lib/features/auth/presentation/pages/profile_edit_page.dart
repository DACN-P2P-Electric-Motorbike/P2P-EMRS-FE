import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ProfileEditPage extends StatefulWidget {
  final UserEntity user;

  const ProfileEditPage({super.key, required this.user});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _avatarCtrl;
  late final TextEditingController _addressCtrl;

  @override
  void initState() {
    super.initState();
    _fullNameCtrl = TextEditingController(text: widget.user.fullName);
    _phoneCtrl = TextEditingController(text: widget.user.phone);
    _avatarCtrl = TextEditingController(text: widget.user.avatarUrl ?? '');
    _addressCtrl = TextEditingController(text: widget.user.address ?? '');
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _avatarCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
      UpdateProfileStarted(
        fullName: _fullNameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        avatarUrl: _avatarCtrl.text.trim().isEmpty
            ? null
            : _avatarCtrl.text.trim(),
        address: _addressCtrl.text.trim().isEmpty
            ? null
            : _addressCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ProfileUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Cập nhật hồ sơ thành công',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop(state.user);
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Chỉnh sửa hồ sơ',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar preview
                    Center(
                      child: Stack(
                        children: [
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _avatarCtrl,
                            builder: (_, value, __) {
                              final url = value.text.trim();
                              return CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColors.surfaceVariant,
                                backgroundImage: url.isNotEmpty
                                    ? NetworkImage(url)
                                    : null,
                                child: url.isEmpty
                                    ? Text(
                                        widget.user.fullName.isNotEmpty
                                            ? widget.user.fullName[0]
                                                .toUpperCase()
                                            : '?',
                                        style: GoogleFonts.poppins(
                                          fontSize: 36,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : null,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    _buildSectionTitle('Thông tin cá nhân'),
                    const SizedBox(height: 12),

                    _buildField(
                      controller: _fullNameCtrl,
                      label: 'Họ và tên',
                      hint: 'Nhập họ và tên',
                      icon: Icons.person_outline_rounded,
                      validator: (v) {
                        if (v == null || v.trim().length < 2) {
                          return 'Họ và tên phải ít nhất 2 ký tự';
                        }
                        return null;
                      },
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 14),

                    _buildField(
                      controller: _phoneCtrl,
                      label: 'Số điện thoại',
                      hint: 'Nhập số điện thoại',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Vui lòng nhập số điện thoại';
                        }
                        final digits = v.trim().replaceAll(' ', '');
                        if (!RegExp(r'^(0|\+84)[3-9]\d{8}$').hasMatch(digits)) {
                          return 'Số điện thoại không hợp lệ';
                        }
                        return null;
                      },
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 14),

                    _buildField(
                      controller: _addressCtrl,
                      label: 'Địa chỉ',
                      hint: 'Nhập địa chỉ (tùy chọn)',
                      icon: Icons.location_on_outlined,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 28),

                    _buildSectionTitle('Ảnh đại diện'),
                    const SizedBox(height: 12),

                    _buildField(
                      controller: _avatarCtrl,
                      label: 'URL ảnh đại diện',
                      hint: 'https://... (tùy chọn)',
                      icon: Icons.image_outlined,
                      keyboardType: TextInputType.url,
                      enabled: !isLoading,
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Lưu thay đổi',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: AppColors.textMuted,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
