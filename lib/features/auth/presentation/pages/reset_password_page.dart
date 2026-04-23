import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';

/// Password strength level
enum _PasswordStrength { none, weak, fair, strong }

class ResetPasswordPage extends StatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordPage({super.key, required this.email, required this.otp});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  _PasswordStrength _strength = _PasswordStrength.none;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    setState(() {
      _strength = _evalStrength(_passwordController.text);
    });
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  _PasswordStrength _evalStrength(String password) {
    if (password.isEmpty) return _PasswordStrength.none;
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    if (score <= 1) return _PasswordStrength.weak;
    if (score == 2 || score == 3) return _PasswordStrength.fair;
    return _PasswordStrength.strong;
  }

  Color get _strengthColor {
    switch (_strength) {
      case _PasswordStrength.weak:
        return AppColors.error;
      case _PasswordStrength.fair:
        return AppColors.warning;
      case _PasswordStrength.strong:
        return AppColors.success;
      case _PasswordStrength.none:
        return Colors.grey[300]!;
    }
  }

  String get _strengthLabel {
    switch (_strength) {
      case _PasswordStrength.weak:
        return 'Yếu';
      case _PasswordStrength.fair:
        return 'Trung bình';
      case _PasswordStrength.strong:
        return 'Mạnh';
      case _PasswordStrength.none:
        return '';
    }
  }

  int get _strengthSegments {
    switch (_strength) {
      case _PasswordStrength.weak:
        return 1;
      case _PasswordStrength.fair:
        return 2;
      case _PasswordStrength.strong:
        return 3;
      case _PasswordStrength.none:
        return 0;
    }
  }

  Future<void> _resetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final dioClient = sl<DioClient>();
      final response = await dioClient.post(
        '/auth/reset-password',
        data: {
          'email': widget.email,
          'otp': widget.otp,
          'newPassword': _passwordController.text,
        },
      );

      if (response.statusCode == 200 && mounted) {
        context.go('/reset-success');
      }
    } on DioException catch (e) {
      if (mounted) {
        String message = 'Không thể đặt lại mật khẩu';
        if (e.response?.data is Map) {
          message = e.response?.data['message'] ?? message;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Step indicator + Back
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const Spacer(),
                      _buildStepIndicator(3),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // Icon
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset_outlined,
                      color: AppColors.primary,
                      size: 36,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Header
                  Text(
                    'Mật khẩu mới',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Mật khẩu mới phải khác với mật khẩu đã dùng trước đây',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 36),

                  // Password Field
                  _buildTextField(
                    controller: _passwordController,
                    hintText: 'Mật khẩu mới',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu mới';
                      }
                      if (value.length < 6) {
                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                      }
                      return null;
                    },
                  ),

                  // Strength meter
                  if (_strength != _PasswordStrength.none) ...[
                    const SizedBox(height: 10),
                    _buildStrengthMeter(),
                  ],

                  const SizedBox(height: 16),

                  // Confirm Password Field
                  _buildTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Xác nhận mật khẩu mới',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        );
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng xác nhận mật khẩu';
                      }
                      if (value != _passwordController.text) {
                        return 'Mật khẩu không khớp';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  // Reset Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SpinKitThreeBounce(
                              color: Colors.white,
                              size: 20,
                            )
                          : Text(
                              'Đặt lại mật khẩu',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStrengthMeter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(3, (i) {
            final filled = i < _strengthSegments;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 4,
                margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                decoration: BoxDecoration(
                  color: filled ? _strengthColor : Colors.grey[200],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              'Độ mạnh: ',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
            Text(
              _strengthLabel,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _strengthColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        _buildCriteria('8+ ký tự', _passwordController.text.length >= 8),
        _buildCriteria(
          '1 chữ hoa',
          RegExp(r'[A-Z]').hasMatch(_passwordController.text),
        ),
        _buildCriteria(
          '1 chữ số',
          RegExp(r'[0-9]').hasMatch(_passwordController.text),
        ),
        _buildCriteria(
          '1 ký tự đặc biệt',
          RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(_passwordController.text),
        ),
      ],
    );
  }

  Widget _buildCriteria(String label, bool met) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_outline : Icons.radio_button_unchecked,
            size: 13,
            color: met ? AppColors.success : Colors.grey[400],
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: met ? AppColors.success : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: !_isLoading,
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 14),
        prefixIcon: Icon(
          prefixIcon,
          color: AppColors.primary.withOpacity(0.7),
          size: 20,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int currentStep) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final step = i + 1;
        final isActive = step == currentStep;
        final isDone = step < currentStep;
        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive || isDone
                    ? AppColors.primary
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            if (i < 2) const SizedBox(width: 4),
          ],
        );
      }),
    );
  }
}
